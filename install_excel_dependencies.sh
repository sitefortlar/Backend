#!/bin/bash

# Script para instalar dependências para processamento de Excel

echo "Instalando dependências para processamento de Excel..."

# Ativa o ambiente virtual se existir
if [ -d ".venv" ]; then
    echo "Ativando ambiente virtual..."
    source .venv/bin/activate
fi

# Instala as dependências
echo "Instalando pandas, openpyxl e python-multipart..."
pip install pandas==2.1.4
pip install openpyxl==3.1.2
pip install python-multipart==0.0.6

echo "Dependências instaladas com sucesso!"
echo ""
echo "Para testar a funcionalidade:"
echo "1. Execute o servidor: uvicorn app.run:app --reload"
echo "2. Acesse: http://localhost:8000/docs"
echo "3. Teste o endpoint: GET /produtos/excel-template"
echo "4. Teste o upload: POST /produtos/upload-excel"
