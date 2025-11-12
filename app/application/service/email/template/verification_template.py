def verification(link: str, token: str) -> str:
    return f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <title>Verifique seu cadastro</title>
        <style>
            body {{ font-family: Arial, sans-serif; background-color: #f5f5f5; }}
            .container {{ background-color: #fff; padding: 20px; max-width: 600px; margin: auto; border-radius: 8px; }}
            h1 {{ color: #333; }}
            a.button {{
                background-color: #0205D3;
                color: white;
                padding: 12px 20px;
                text-decoration: none;
                border-radius: 5px;
                display: inline-block;
            }}
            a.button:hover {{ background-color: #0103A0; }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Confirme seu cadastro</h1>
            <p>Obrigado por se cadastrar! Para ativar sua conta, clique no botão abaixo:</p>
            <p><b>Token de validação:</b> {token}</p>
            <a href="{link}" class="button">Verificar Conta</a>
            <p>Se você não se cadastrou, ignore este e-mail.</p>
        </div>
    </body>
    </html>
    """
