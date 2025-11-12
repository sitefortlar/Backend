"""Router para upload de planilha Excel com processamento de imagens"""

from fastapi import APIRouter, UploadFile, File, HTTPException, status, Depends
from fastapi.responses import JSONResponse
from loguru import logger

from app.application.usecases.impl.upload_planilha_use_case import UploadPlanilhaUseCase
from app.infrastructure.utils.file_utils import validate_excel_file

upload_router = APIRouter(
    prefix="/upload",
    tags=["Upload"],
    responses={
        400: {"description": "Arquivo inválido"},
        422: {"description": "Dados inválidos"},
        500: {"description": "Erro interno do servidor"}
    }
)


@upload_router.post(
    "/planilha-imagens",
    summary="Upload de planilha Excel com processamento de imagens",
    description="""
    Faz upload de uma planilha Excel (.xlsx) com colunas: codigo, nome, imagem_url.
    
    O sistema irá:
    1. Ler a planilha Excel
    2. Converter links do Google Drive para formato direto
    3. Fazer download das imagens
    4. Enviar as imagens para o Supabase Storage
    5. Gerar links públicos das imagens
    6. Criar uma nova planilha com coluna adicional 'imagem_supabase'
    7. Salvar o Excel atualizado no Supabase Storage
    8. Retornar a URL do Excel no Supabase
    
    **Formato da planilha:**
    - codigo: Código do produto (será usado como nome do arquivo)
    - nome: Nome do produto
    - imagem_url: URL única ou array de URLs do Google Drive
    
    **Formato de imagem_url:**
    - URL única: "https://drive.google.com/uc?export=view&id=..."
    - Array de URLs: "[url1, url2, url3]" (sem aspas nas URLs, separado por vírgula)
    
    **Retorno:**
    - JSON com URL do Excel atualizado no Supabase e estatísticas do processamento
    """
)
async def upload_planilha_imagens(
    file: UploadFile = File(..., description="Arquivo Excel (.xlsx) com colunas: codigo, nome, imagem_url")
):
    """
    Endpoint para upload e processamento de planilha Excel com imagens
    Retorna JSON com URL do Excel atualizado no Supabase
    """
    try:
        # Valida nome do arquivo
        if not file.filename:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Nome do arquivo é obrigatório"
            )
        
        # Valida extensão do arquivo
        if not validate_excel_file(file.filename):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Arquivo deve ser .xlsx ou .xls"
            )
        
        logger.info(f"Iniciando upload de planilha: {file.filename}")
        
        # Lê o conteúdo do arquivo
        file_bytes = await file.read()
        
        if not file_bytes:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Arquivo está vazio"
            )
        
        logger.info(f"Arquivo recebido: {len(file_bytes)} bytes")
        
        # Executa o use case
        use_case = UploadPlanilhaUseCase()
        request_data = {
            'file_bytes': file_bytes
        }
        
        try:
            logger.info("Executando use case para processar planilha")
            result = use_case.execute(request_data)  # Agora retorna dict
            logger.info(f"Use case executado com sucesso")
            
            # Retorna JSON com a URL e estatísticas
            return JSONResponse(
                status_code=status.HTTP_200_OK,
                content={
                    "success": True,
                    "excel_url": result["excel_url"],
                    "excel_filename": result["excel_filename"],
                    "total_linhas": result["total_linhas"],
                    "linhas_processadas": result["linhas_processadas"],
                    "total_imagens_salvas": result["total_imagens_salvas"],
                    "erros": result["erros"],
                    "mensagem": result["mensagem"]
                }
            )
            
        except ValueError as e:
            logger.error(f"Erro de validação na planilha: {e}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Erro de validação: {str(e)}"
            )
        except FileNotFoundError as e:
            logger.error(f"Arquivo não encontrado: {e}")
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Arquivo não encontrado: {str(e)}"
            )
        except Exception as e:
            logger.error(f"Erro no processamento da planilha: {e}", exc_info=True)
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Erro ao processar planilha: {str(e)}"
            )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erro inesperado no upload: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro inesperado: {str(e)}"
        )

