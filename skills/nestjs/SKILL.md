---
name: nestjs
description: NestJS patterns and best practices. Use when building REST APIs, modules, services, controllers, guards, interceptors, DTOs, or testing NestJS applications.
---

# NestJS Best Practices

## Architecture — Controller → Service → Repository

```
src/
  modules/
    users/
      users.module.ts
      users.controller.ts     ← HTTP only, no business logic
      users.service.ts        ← business logic
      users.repository.ts     ← data access (Prisma/TypeORM)
      dto/
        create-user.dto.ts
        update-user.dto.ts
      entities/
        user.entity.ts
      __tests__/
        users.service.spec.ts
        users.controller.spec.ts
```

**Rule:** Feature modules only. Never use the root AppModule for business logic.

---

## Controllers — thin layer

Controllers handle only HTTP concerns: parsing request, calling service, returning response.

```ts
@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  findAll(@Query() query: PaginationDto): Promise<PaginatedResult<User>> {
    return this.usersService.findAll(query);
  }

  @Get(':id')
  findOne(@Param('id') id: string): Promise<User> {
    return this.usersService.findOne(id);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() dto: CreateUserDto, @CurrentUser() user: AuthUser): Promise<User> {
    return this.usersService.create(dto, user.tenantId);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateUserDto): Promise<User> {
    return this.usersService.update(id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string): Promise<void> {
    return this.usersService.remove(id);
  }
}
```

**Rules:**
- No `try/catch` in controllers — use exception filters
- No business logic — delegate everything to service
- Always type return values
- Use `@HttpCode` explicitly for non-200 responses

---

## Services — business logic lives here

```ts
@Injectable()
export class UsersService {
  constructor(private readonly usersRepository: UsersRepository) {}

  async findAll(query: PaginationDto): Promise<PaginatedResult<User>> {
    return this.usersRepository.findAllPaginated(query);
  }

  async findOne(id: string): Promise<User> {
    const user = await this.usersRepository.findById(id);
    if (!user) throw new NotFoundException(`User ${id} not found`);
    return user;
  }

  async create(dto: CreateUserDto, tenantId: string): Promise<User> {
    const existing = await this.usersRepository.findByEmail(dto.email);
    if (existing) throw new ConflictException('Email already in use');
    return this.usersRepository.create({ ...dto, tenantId });
  }

  async update(id: string, dto: UpdateUserDto): Promise<User> {
    await this.findOne(id); // throws NotFoundException if not found
    return this.usersRepository.update(id, dto);
  }

  async remove(id: string): Promise<void> {
    await this.findOne(id);
    await this.usersRepository.delete(id);
  }
}
```

**Rules:**
- Use NestJS built-in exceptions: `NotFoundException`, `ConflictException`, `ForbiddenException`, `UnauthorizedException`, `BadRequestException`
- Services are stateless — no instance state
- Business rules live here, not in controllers or repos

---

## DTOs — validation at the boundary

```ts
import { IsEmail, IsString, MinLength, IsOptional, IsEnum } from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateUserDto {
  @IsEmail()
  @Transform(({ value }) => value.toLowerCase().trim())
  email: string;

  @IsString()
  @MinLength(2)
  name: string;

  @IsEnum(UserRole)
  role: UserRole;
}

export class UpdateUserDto extends PartialType(CreateUserDto) {}

export class PaginationDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}
```

**Rules:**
- Always use `PartialType` for update DTOs — never duplicate fields
- Always validate at the boundary — no raw `req.body`
- Use `@Transform` for normalization (lowercase, trim)
- Enable `ValidationPipe` globally in `main.ts`:

```ts
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,        // strip unknown properties
  forbidNonWhitelisted: true,
  transform: true,        // auto-transform types
  transformOptions: { enableImplicitConversion: true },
}));
```

---

## Repository pattern

```ts
@Injectable()
export class UsersRepository {
  constructor(private readonly prisma: PrismaService) {}

  findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { id } });
  }

  findByEmail(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { email } });
  }

  async findAllPaginated(query: PaginationDto): Promise<PaginatedResult<User>> {
    const { page, limit } = query;
    const skip = (page - 1) * limit;

    const [data, total] = await this.prisma.$transaction([
      this.prisma.user.findMany({ skip, take: limit }),
      this.prisma.user.count(),
    ]);

    return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  create(data: Prisma.UserCreateInput): Promise<User> {
    return this.prisma.user.create({ data });
  }

  update(id: string, data: Prisma.UserUpdateInput): Promise<User> {
    return this.prisma.user.update({ where: { id }, data });
  }

  delete(id: string): Promise<User> {
    return this.prisma.user.delete({ where: { id } });
  }
}
```

**Rules:**
- Repository returns `null` (not throws) when not found — service decides what to do
- Use `$transaction` for atomic operations
- Never put business logic in repos — only data access

---

## Guards

```ts
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext) {
    return super.canActivate(context);
  }
}

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const roles = this.reflector.getAllAndOverride<UserRole[]>('roles', [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!roles) return true;

    const { user } = context.switchToHttp().getRequest();
    return roles.includes(user.role);
  }
}

// Decorator
export const Roles = (...roles: UserRole[]) => SetMetadata('roles', roles);

// Usage
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
@Delete(':id')
remove(@Param('id') id: string) { ... }
```

---

## Custom decorators

```ts
// Extract current user from request
export const CurrentUser = createParamDecorator(
  (data: keyof AuthUser | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user as AuthUser;
    return data ? user[data] : user;
  },
);

// Usage
create(@Body() dto: CreateDto, @CurrentUser() user: AuthUser) { ... }
create(@Body() dto: CreateDto, @CurrentUser('tenantId') tenantId: string) { ... }
```

---

## Exception handling

```ts
// Custom exception
export class TenantNotFoundException extends NotFoundException {
  constructor(tenantId: string) {
    super(`Tenant ${tenantId} not found`);
  }
}

// Global exception filter (optional, for consistent error shape)
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    const status = exception instanceof HttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    const message = exception instanceof HttpException
      ? exception.getResponse()
      : 'Internal server error';

    response.status(status).json({
      statusCode: status,
      message,
      timestamp: new Date().toISOString(),
    });
  }
}
```

---

## Module structure

```ts
@Module({
  imports: [
    TypeOrmModule.forFeature([User]),  // or PrismaModule
  ],
  controllers: [UsersController],
  providers: [UsersService, UsersRepository],
  exports: [UsersService],  // only export what other modules need
})
export class UsersModule {}
```

**Rules:**
- Export services, not repositories
- Import only what the module uses
- Never use `forRoot` in feature modules

---

## Testing

### Unit test — Service

```ts
describe('UsersService', () => {
  let service: UsersService;
  let repository: jest.Mocked<UsersRepository>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: UsersRepository,
          useValue: {
            findById: jest.fn(),
            findByEmail: jest.fn(),
            create: jest.fn(),
            update: jest.fn(),
            delete: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get(UsersService);
    repository = module.get(UsersRepository);
  });

  describe('findOne', () => {
    it('returns user when found', async () => {
      repository.findById.mockResolvedValue(mockUser);
      const result = await service.findOne('1');
      expect(result).toEqual(mockUser);
    });

    it('throws NotFoundException when not found', async () => {
      repository.findById.mockResolvedValue(null);
      await expect(service.findOne('1')).rejects.toThrow(NotFoundException);
    });
  });
});
```

### Unit test — Controller

```ts
describe('UsersController', () => {
  let controller: UsersController;
  let service: jest.Mocked<UsersService>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [{
        provide: UsersService,
        useValue: { findOne: jest.fn(), create: jest.fn() },
      }],
    }).compile();

    controller = module.get(UsersController);
    service = module.get(UsersService);
  });

  it('calls service.findOne with correct id', async () => {
    service.findOne.mockResolvedValue(mockUser);
    await controller.findOne('1');
    expect(service.findOne).toHaveBeenCalledWith('1');
  });
});
```

---

## Anti-patterns to avoid

```ts
// ❌ Business logic in controller
@Post()
async create(@Body() dto: CreateUserDto) {
  const existing = await this.prisma.user.findUnique({ where: { email: dto.email } });
  if (existing) throw new ConflictException();
  return this.prisma.user.create({ data: dto });
}

// ✅ Controller delegates, service decides
@Post()
create(@Body() dto: CreateUserDto): Promise<User> {
  return this.usersService.create(dto);
}

// ❌ Repository throws business exceptions
findById(id: string): Promise<User> {
  const user = await this.prisma.user.findUnique({ where: { id } });
  if (!user) throw new NotFoundException(); // ← no, this is service's job
  return user;
}

// ✅ Repository returns null, service handles it
findById(id: string): Promise<User | null> {
  return this.prisma.user.findUnique({ where: { id } });
}

// ❌ Leaking Prisma types to controllers
@Get(':id')
findOne(@Param('id') id: string): Promise<Prisma.UserGetPayload<...>> { ... }

// ✅ Use domain types or response DTOs
@Get(':id')
findOne(@Param('id') id: string): Promise<UserResponseDto> { ... }
```
