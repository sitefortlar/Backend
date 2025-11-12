"""Container de dependências para injeção de dependência"""

# Services
from app.application.service.email_service import EmailService
from app.application.service.hash_service import HashService
from app.application.service.jwt_service import JWTService
from app.application.service.excel_service import ExcelService

# Use Cases - Company
from app.application.usecases.impl.create_company_use_case import CreateCompanyUseCase
from app.application.usecases.impl.list_companies_use_case import ListCompaniesUseCase
from app.application.usecases.impl.get_company_use_case import GetCompanyUseCase
from app.application.usecases.impl.update_company_use_case import UpdateCompanyUseCase
from app.application.usecases.impl.delete_company_use_case import DeleteCompanyUseCase

# Use Cases - Product
from app.application.usecases.impl.list_products_use_case import ListProdutosUseCase
from app.application.usecases.impl.bulk_create_produtos_use_case import BulkCreateProdutosUseCase

# Use Cases - Order
from app.application.usecases.impl.list_orders_use_case import ListOrdersUseCase
from app.application.usecases.impl.get_order_use_case import GetOrderUseCase
from app.application.usecases.impl.list_recent_orders_use_case import ListOrdersRecentesUseCase

# Use Cases - Auth
from app.application.usecases.impl.login_use_case import LoginUseCase
from app.application.usecases.impl.forgot_use_case import ForgotPasswordUseCase
from app.application.usecases.impl.reset_use_case import ResetPasswordUseCase
from app.application.usecases.impl.verify_user_permission_use_case import VerifyUserPermissionUseCase

# Use Cases - External APIs
from app.application.usecases.impl.get_address_by_cep_use_case import GetAddressByCepUseCase
from app.application.usecases.impl.get_company_by_cnpj_use_case import GetCompanyByCnpjUseCase

# Providers
from app.infrastructure.providers.impl.cep_provider_impl import CEPProviderImpl
from app.infrastructure.providers.impl.cnpj_provider_impl import CNPJProviderImpl

# Repositories
from app.infrastructure.repositories.impl.company_repository_impl import CompanyRepositoryImpl
from app.infrastructure.repositories.impl.contact_repository_impl import ContactRepositoryImpl
from app.infrastructure.repositories.impl.address_repository_impl import AddressRepositoryImpl
from app.infrastructure.repositories.impl.product_repository_impl import ProductRepositoryImpl
from app.infrastructure.repositories.impl.category_repository_impl import CategoryRepositoryImpl
from app.infrastructure.repositories.impl.order_repository_impl import OrderRepositoryImpl
from app.infrastructure.repositories.impl.kit_repository_impl import KitRepository
from app.infrastructure.repositories.impl.email_token_repository_impl import EmailTokenRepositoryImpl
from app.infrastructure.repositories.impl.subcategory_repository_impl import SubcategoryRepositoryImpl


class DependencyContainer:
    """Container para gerenciar dependências da aplicação"""

    def __init__(self):
        # Services
        self._hash_service = HashService()
        self._email_service = EmailService()
        self._jwt_service = JWTService()

        # Repositories
        self._company_repository = CompanyRepositoryImpl()
        self._contact_repository = ContactRepositoryImpl()
        self._address_repository = AddressRepositoryImpl()
        self._produto_repository = ProductRepositoryImpl()
        self._categoria_repository = CategoryRepositoryImpl()
        self._pedido_repository = OrderRepositoryImpl()
        self._kit_repository = KitRepository()
        self._email_token_repository = EmailTokenRepositoryImpl()
        self._subcategoria_repository = SubcategoryRepositoryImpl()
        self._cep_provider = CEPProviderImpl()
        self._cnpj_provider = CNPJProviderImpl()
        # Use Cases - Company
        self._create_company_use_case = CreateCompanyUseCase(
            company_repository=self._company_repository,
            email_token_repository=self._email_token_repository,
            hash_service=self._hash_service,
            email_service=self._email_service
        )

        self._list_companies_use_case = ListCompaniesUseCase(
            company_repository=self._company_repository
        )

        self._get_company_use_case = GetCompanyUseCase(
            company_repository=self._company_repository
        )

        self._update_company_use_case = UpdateCompanyUseCase(
            company_repository=self._company_repository
        )

        self._delete_company_use_case = DeleteCompanyUseCase(
            company_repository=self._company_repository
        )

        # Use Cases - Product
        self._list_produtos_use_case = ListProdutosUseCase(
            produto_repository=self._produto_repository
        )

        # Use Cases - Order
        self._list_pedidos_use_case = ListOrdersUseCase(
            pedido_repository=self._pedido_repository
        )

        self._get_pedido_use_case = GetOrderUseCase(
            pedido_repository=self._pedido_repository
        )

        self._list_pedidos_recentes_use_case = ListOrdersRecentesUseCase(
            pedido_repository=self._pedido_repository
        )

        # Use Cases - Auth
        self._login_use_case = LoginUseCase(
            company_repository=self._company_repository,
            hash_service=self._hash_service,
            jwt_service=self._jwt_service
        )
        self._forgot_password_use_case = ForgotPasswordUseCase(
            company_repository=self._company_repository,
            email_token_repository=self._email_token_repository,
            email_service=self._email_service,
            hash_service=self._hash_service
        )
        self._reset_password_use_case = ResetPasswordUseCase(
            company_repository=self._company_repository,
            email_token_repository=self._email_token_repository,
            hash_service=self._hash_service
        )
        self._verify_user_permission_use_case = VerifyUserPermissionUseCase()

        # Use Cases - CEP e CNPJ
        self._get_address_by_cep_use_case = GetAddressByCepUseCase(cep_provider=self._cep_provider)
        self._get_company_by_cnpj_use_case = GetCompanyByCnpjUseCase(cnpj_provider=self._cnpj_provider)

        # Services
        self._excel_service = ExcelService()

        # Use Cases - Bulk Operations
        self._bulk_create_produtos_use_case = BulkCreateProdutosUseCase(
            produto_repository=self._produto_repository,
            categoria_repository=self._categoria_repository,
            subcategoria_repository=self._subcategoria_repository,
            excel_service=self._excel_service
        )

    # Company Use Cases
    @property
    def create_company_use_case(self) -> CreateCompanyUseCase:
        return self._create_company_use_case

    @property
    def list_companies_use_case(self) -> ListCompaniesUseCase:
        return self._list_companies_use_case

    @property
    def get_company_use_case(self) -> GetCompanyUseCase:
        return self._get_company_use_case

    @property
    def update_company_use_case(self) -> UpdateCompanyUseCase:
        return self._update_company_use_case

    @property
    def delete_company_use_case(self) -> DeleteCompanyUseCase:
        return self._delete_company_use_case

    # Product Use Cases
    @property
    def list_produtos_use_case(self) -> ListProdutosUseCase:
        return self._list_produtos_use_case

    # Order Use Cases
    @property
    def list_pedidos_use_case(self) -> ListOrdersUseCase:
        return self._list_pedidos_use_case

    @property
    def get_pedido_use_case(self) -> GetOrderUseCase:
        return self._get_pedido_use_case

    @property
    def list_pedidos_recentes_use_case(self) -> ListOrdersRecentesUseCase:
        return self._list_pedidos_recentes_use_case

    # Auth Use Cases
    @property
    def login_use_case(self) -> LoginUseCase:
        return self._login_use_case

    @property
    def forgot_password_use_case(self) -> ForgotPasswordUseCase:
        return self._forgot_password_use_case

    @property
    def reset_password_use_case(self) -> ResetPasswordUseCase:
        return self._reset_password_use_case

    @property
    def verify_user_permission_use_case(self) -> VerifyUserPermissionUseCase:
        return self._verify_user_permission_use_case

    # Bulk Operations Use Cases
    @property
    def bulk_create_produtos_use_case(self) -> BulkCreateProdutosUseCase:
        return self._bulk_create_produtos_use_case

    # CEP
    @property
    def get_address_by_cep_use_case(self) -> GetAddressByCepUseCase:
        return self._get_address_by_cep_use_case

    # CNPJ
    @property
    def get_company_by_cnpj_use_case(self) -> GetCompanyByCnpjUseCase:
        return self._get_company_by_cnpj_use_case

    # Services
    @property
    def excel_service(self) -> ExcelService:
        return self._excel_service

    # Services
    @property
    def hash_service(self) -> HashService:
        return self._hash_service

    @property
    def email_service(self) -> EmailService:
        return self._email_service

    @property
    def jwt_service(self) -> JWTService:
        return self._jwt_service

    # Repositories
    @property
    def company_repository(self) -> CompanyRepositoryImpl:
        return self._company_repository

    @property
    def contact_repository(self) -> ContactRepositoryImpl:
        return self._contact_repository

    @property
    def address_repository(self) -> AddressRepositoryImpl:
        return self._address_repository

    @property
    def produto_repository(self) -> ProductRepositoryImpl:
        return self._produto_repository

    @property
    def categoria_repository(self) -> CategoryRepositoryImpl:
        return self._categoria_repository

    @property
    def pedido_repository(self) -> OrderRepositoryImpl:
        return self._pedido_repository

    @property
    def kit_repository(self) -> KitRepository:
        return self._kit_repository

    @property
    def subcategoria_repository(self) -> SubcategoryRepositoryImpl:
        return self._subcategoria_repository

    @property
    def email_token_repository(self) -> EmailTokenRepositoryImpl:
        return self._email_token_repository





# Instância global do container
container = DependencyContainer()
