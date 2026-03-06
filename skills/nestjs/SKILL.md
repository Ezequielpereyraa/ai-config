---
name: nestjs
description: NestJS patterns and best practices. Use when building REST APIs, modules, services, controllers, guards, interceptors, DTOs, or testing NestJS applications.
---

# NestJS — Senior Patterns & Best Practices

> Controller → Service → Repository. Sin excepciones.

## Module Structure

```
src/
  modules/
    users/
      users.module.ts
      users.controller.ts     ← HTTP only, no business logic
      users.service.ts        ← business logic
      users.repository.ts     ← data access (Prisma)
      dto/
        create-user.dto.ts
        update-user.dto.ts
      __tests__/
        users.service.spec.ts
```

**Rule:** Feature modules only. AppModule solo importa feature modules.

## Controller — thin layer

```ts
@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  findAll(@Query() query: PaginationDto): Promise<PaginatedResult<IUser>> {
    return this.usersService.findAll(query)
  }

  @Get(':id')
  findOne(@Param('id') id: string): Promise<IUser> {
    return this.usersService.findOne(id)
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() dto: CreateUserDto, @CurrentUser() user: IAuthUser): Promise<IUser> {
    return this.usersService.create(dto, user.tenantId)
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateUserDto): Promise<IUser> {
    return this.usersService.update(id, dto)
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string): Promise<void> {
    return this.usersService.remove(id)
  }
}
```

**Rules:**
- Sin `try/catch` — usar exception filters
- Sin lógica de negocio — delegar todo al service
- `@HttpCode` explícito para respuestas non-200

## Service — business logic

```ts
@Injectable()
export class UsersService {
  constructor(private readonly usersRepository: UsersRepository) {}

  async findOne(id: string): Promise<IUser> {
    const user = await this.usersRepository.findById(id)
    if (!user) throw new NotFoundException(`User ${id} not found`)
    return user
  }

  async create(dto: CreateUserDto, tenantId: string): Promise<IUser> {
    const existing = await this.usersRepository.findByEmail(dto.email)
    if (existing) throw new ConflictException('Email already in use')
    return this.usersRepository.create({ ...dto, tenantId })
  }

  async update(id: string, dto: UpdateUserDto): Promise<IUser> {
    await this.findOne(id)  // throws NotFoundException if not found
    return this.usersRepository.update(id, dto)
  }

  async remove(id: string): Promise<void> {
    await this.findOne(id)
    await this.usersRepository.delete(id)
  }
}
```

**Excepciones built-in:** `NotFoundException` · `ConflictException` · `ForbiddenException` · `UnauthorizedException` · `BadRequestException`

## DTOs — validación en el límite

```ts
export class CreateUserDto {
  @IsEmail()
  @Transform(({ value }) => value.toLowerCase().trim())
  email: string

  @IsString()
  @MinLength(2)
  name: string

  @IsEnum(UserRole)
  role: UserRole
}

export class UpdateUserDto extends PartialType(CreateUserDto) {}

export class PaginationDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Max(100)
  limit?: number = 20
}
```

**`main.ts` — ValidationPipe global:**

```ts
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,
  forbidNonWhitelisted: true,
  transform: true,
  transformOptions: { enableImplicitConversion: true },
}))
```

## Repository — data access only

```ts
@Injectable()
export class UsersRepository {
  constructor(private readonly prisma: PrismaService) {}

  findById(id: string): Promise<IUser | null> {
    return this.prisma.user.findUnique({ where: { id } })
  }

  findByEmail(email: string): Promise<IUser | null> {
    return this.prisma.user.findUnique({ where: { email } })
  }

  async findAllPaginated(query: PaginationDto): Promise<PaginatedResult<IUser>> {
    const skip = (query.page - 1) * query.limit
    const [data, total] = await this.prisma.$transaction([
      this.prisma.user.findMany({ skip, take: query.limit }),
      this.prisma.user.count(),
    ])
    return { data, total, page: query.page, limit: query.limit, totalPages: Math.ceil(total / query.limit) }
  }

  create(data: Prisma.UserCreateInput): Promise<IUser> {
    return this.prisma.user.create({ data })
  }

  update(id: string, data: Prisma.UserUpdateInput): Promise<IUser> {
    return this.prisma.user.update({ where: { id }, data })
  }

  delete(id: string): Promise<IUser> {
    return this.prisma.user.delete({ where: { id } })
  }
}
```

**Rule:** Repository retorna `null` cuando no encuentra — el service decide qué hacer. Nunca lanza excepciones de negocio.

## Guards

```ts
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const roles = this.reflector.getAllAndOverride<UserRole[]>('roles', [
      context.getHandler(),
      context.getClass(),
    ])
    if (!roles) return true
    const { user } = context.switchToHttp().getRequest()
    return roles.includes(user.role)
  }
}

export const Roles = (...roles: UserRole[]) => SetMetadata('roles', roles)

// Usage
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
@Delete(':id')
remove(@Param('id') id: string) {}
```

## Custom Decorators

```ts
export const CurrentUser = createParamDecorator(
  (data: keyof IAuthUser | undefined, ctx: ExecutionContext) => {
    const user = ctx.switchToHttp().getRequest().user as IAuthUser
    return data ? user[data] : user
  },
)

// Usage
create(@Body() dto: CreateDto, @CurrentUser() user: IAuthUser) {}
create(@Body() dto: CreateDto, @CurrentUser('tenantId') tenantId: string) {}
```

## Exception Filter — forma consistente de errores

```ts
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp()
    const status = exception instanceof HttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR
    const message = exception instanceof HttpException
      ? exception.getResponse()
      : 'Internal server error'

    ctx.getResponse<Response>().status(status).json({ statusCode: status, message })
  }
}
```

## Module

```ts
@Module({
  controllers: [UsersController],
  providers: [UsersService, UsersRepository],
  exports: [UsersService],  // exportar services, nunca repositories
})
export class UsersModule {}
```

## Testing — NestJS Testing Module

```ts
describe('UsersService', () => {
  let service: UsersService
  let repository: jest.Mocked<UsersRepository>

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: UsersRepository,
          useValue: { findById: jest.fn(), findByEmail: jest.fn(), create: jest.fn() },
        },
      ],
    }).compile()

    service = module.get(UsersService)
    repository = module.get(UsersRepository)
  })

  it('throws NotFoundException when user not found', async () => {
    repository.findById.mockResolvedValue(null)
    await expect(service.findOne('1')).rejects.toThrow(NotFoundException)
  })
})
```

## Upgrade Nudges — Patterns to Flag

| If you see this | Suggest this |
|---|---|
| Business logic in controller | Move to service |
| `throw NotFoundException` in repository | Return `null`, let service throw |
| Prisma types leaked to controller return type | Use domain interface or response DTO |
| `UpdateUserDto` with duplicated fields | `PartialType(CreateUserDto)` |
| No `whitelist: true` in ValidationPipe | Add — strips unknown properties |
| Raw `req.body` without DTO | Create DTO with class-validator |
| `@UseGuards` without `@Roles` | Probably missing role restriction |
| No `$transaction` for multi-step writes | Wrap in `prisma.$transaction` |
