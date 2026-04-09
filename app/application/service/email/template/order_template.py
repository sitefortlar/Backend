"""Template HTML para email de order"""


def order_html(
    itens: list,
    subtotal_sem_ipi: float,
    valor_ipi: float,
    total_com_ipi: float,
    forma_pagamento: str,
    empresa_nome: str = "",
    endereco = None,
    contato = None
) -> str:
    """
    Gera HTML formatado para email de order com informações completas do cliente
    
    Args:
        itens: Lista de itens com informações do produto (codigo, nome, quantidade, preco_unitario, subtotal)
        subtotal_sem_ipi: Soma dos itens (base para IPI)
        valor_ipi: IPI 6,5% sobre o subtotal
        total_com_ipi: Subtotal + IPI
        forma_pagamento: Forma de pagamento escolhida (À Vista, 30 Dias, 60 Dias)
        empresa_nome: Nome da empresa/cliente
        endereco: Objeto Address com dados do endereço
        contato: Objeto Contact com dados do contato
    
    Returns:
        HTML formatado do order
    """
    
    # Constrói a tabela de itens
    itens_html = ""
    for item in itens:
        codigo = item.get('codigo') or 'N/A'
        nome_produto = item.get('nome', 'Produto')
        quantidade = item.get('quantidade', 0)
        preco_unitario = item.get('preco_unitario', 0.0)
        subtotal = item.get('subtotal', 0.0)
        
        itens_html += f"""
        <tr>
            <td style="padding: 12px; border-bottom: 1px solid #ddd;">{codigo}</td>
            <td style="padding: 12px; border-bottom: 1px solid #ddd;">{nome_produto}</td>
            <td style="padding: 12px; border-bottom: 1px solid #ddd; text-align: center;">{quantidade}</td>
            <td style="padding: 12px; border-bottom: 1px solid #ddd; text-align: right;">R$ {preco_unitario:.2f}</td>
            <td style="padding: 12px; border-bottom: 1px solid #ddd; text-align: right;">R$ {subtotal:.2f}</td>
        </tr>
        """
    
    # Seção de endereço
    endereco_html = ""
    if endereco:
        endereco_parts = []
        if endereco.cep:
            endereco_parts.append(f"CEP: {endereco.cep}")
        if endereco.numero:
            endereco_parts.append(f"Nº {endereco.numero}")
        if endereco.complemento:
            endereco_parts.append(f"Complemento: {endereco.complemento}")
        if endereco.bairro:
            endereco_parts.append(f"Bairro: {endereco.bairro}")
        if endereco.cidade or endereco.uf:
            cidade_uf = f"{endereco.cidade or ''} - {endereco.uf or ''}".strip(' -')
            if cidade_uf:
                endereco_parts.append(cidade_uf)
        
        endereco_texto = "<br>".join(endereco_parts) if endereco_parts else "Endereço não informado"
        
        endereco_html = f"""
        <div class="section">
            <div class="section-title">📍 Endereço de Entrega</div>
            <div class="info-box">
                {endereco_texto}
            </div>
        </div>
        """
    
    # Seção de contato
    contato_html = ""
    if contato:
        contato_parts = []
        if contato.nome:
            contato_parts.append(f"<strong>Nome:</strong> {contato.nome}")
        if contato.email:
            contato_parts.append(f"<strong>Email:</strong> {contato.email}")
        if contato.telefone:
            contato_parts.append(f"<strong>Telefone:</strong> {contato.telefone}")
        if contato.celular:
            contato_parts.append(f"<strong>Celular:</strong> {contato.celular}")
        
        contato_texto = "<br>".join(contato_parts) if contato_parts else "Contato não informado"
        
        contato_html = f"""
        <div class="section">
            <div class="section-title">📞 Contato do Cliente</div>
            <div class="info-box">
                {contato_texto}
            </div>
        </div>
        """
    
    html = f"""
    <!DOCTYPE html>
    <html lang="pt-BR">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Pedido - Fortlar</title>
        <style>
            body {{
                font-family: Arial, sans-serif;
                line-height: 1.6;
                color: #333;
                background-color: #f4f4f4;
                margin: 0;
                padding: 0;
            }}
            .container {{
                max-width: 600px;
                margin: 20px auto;
                background-color: #ffffff;
                border-radius: 8px;
                overflow: hidden;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }}
            .header {{
                background-color: #2c3e50;
                color: #ffffff;
                padding: 20px;
                text-align: center;
            }}
            .header h1 {{
                margin: 0;
                font-size: 24px;
            }}
            .content {{
                padding: 30px;
            }}
            .section {{
                margin-bottom: 30px;
            }}
            .section-title {{
                font-size: 18px;
                font-weight: bold;
                color: #2c3e50;
                margin-bottom: 15px;
                border-bottom: 2px solid #3498db;
                padding-bottom: 10px;
            }}
            .info-box {{
                background-color: #f8f9fa;
                padding: 15px;
                border-radius: 5px;
                border-left: 4px solid #3498db;
            }}
            table {{
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 20px;
            }}
            th {{
                background-color: #3498db;
                color: #ffffff;
                padding: 12px;
                text-align: left;
                font-weight: bold;
            }}
            th.text-center {{
                text-align: center;
            }}
            th.text-right {{
                text-align: right;
            }}
            td {{
                padding: 12px;
                border-bottom: 1px solid #ddd;
            }}
            .total-section {{
                background-color: #ecf0f1;
                padding: 15px;
                border-radius: 5px;
                margin-top: 20px;
            }}
            .total-row {{
                display: flex;
                justify-content: space-between;
                font-size: 16px;
                color: #2c3e50;
                margin-bottom: 8px;
            }}
            .total-row.final {{
                font-size: 18px;
                font-weight: bold;
                margin-top: 12px;
                padding-top: 12px;
                border-top: 1px solid #bdc3c7;
            }}
            .payment-info {{
                background-color: #fff3cd;
                padding: 20px;
                border-radius: 5px;
                border-left: 5px solid #ffc107;
                margin-top: 20px;
            }}
            .payment-info strong {{
                color: #856404;
                font-size: 16px;
            }}
            .payment-method {{
                font-size: 20px;
                color: #856404;
                font-weight: bold;
                margin-top: 10px;
                text-align: center;
                padding: 10px;
                background-color: #fff;
                border-radius: 4px;
            }}
            .footer {{
                background-color: #34495e;
                color: #ffffff;
                padding: 15px;
                text-align: center;
                font-size: 12px;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🛒 Novo Order - Fortlar</h1>
                {f'<p style="margin: 10px 0 0 0; font-size: 14px;">Cliente: {empresa_nome}</p>' if empresa_nome else ''}
            </div>
            
            <div class="content">
                {contato_html}
                
                {endereco_html}
                
                <div class="section">
                    <div class="section-title">📦 Itens do Order</div>
                    <table>
                        <thead>
                            <tr>
                                <th>Código</th>
                                <th>Produto</th>
                                <th class="text-center">Quantidade</th>
                                <th class="text-right">Preço Unitário</th>
                                <th class="text-right">Subtotal</th>
                            </tr>
                        </thead>
                        <tbody>
                            {itens_html}
                        </tbody>
                    </table>
                </div>
                
                <div class="total-section">
                    <div class="total-row">
                        <span>Subtotal (sem IPI):</span>
                        <span>R$ {subtotal_sem_ipi:.2f}</span>
                    </div>
                    <div class="total-row">
                        <span>IPI (6,5%):</span>
                        <span>R$ {valor_ipi:.2f}</span>
                    </div>
                    <div class="total-row final">
                        <span>Total com IPI:</span>
                        <span>R$ {total_com_ipi:.2f}</span>
                    </div>
                </div>
                
                <div class="payment-info">
                    <strong>💳 Forma de Pagamento:</strong>
                    <div class="payment-method">{forma_pagamento}</div>
                </div>
            </div>
            
            <div class="footer">
                <p>Este é um email automático. Por favor, não responda.</p>
                <p>&copy; 2024 Fortlar. Todos os direitos reservados.</p>
            </div>
        </div>
    </body>
    </html>
    """
    
    return html

