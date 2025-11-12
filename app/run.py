from dotenv import load_dotenv
import uvicorn

from app.application.service.hash_service import HashService
from app.infrastructure.configs.fastapi_config import application

load_dotenv()

# Alias para compatibilidade com uvicorn
app = application

if __name__ == '__main__':
    hash_service = HashService()
    password_hash = hash_service.hash_password("12.345.678/0001-99")
    print("Hash gerado:", password_hash)
    uvicorn.run(application, port=8088)



