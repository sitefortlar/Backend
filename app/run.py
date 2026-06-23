from dotenv import load_dotenv
import uvicorn

from app.infrastructure.configs.fastapi_config import application

load_dotenv()

app = application

if __name__ == '__main__':
    uvicorn.run(application, host="0.0.0.0", port=8000, reload=True)
