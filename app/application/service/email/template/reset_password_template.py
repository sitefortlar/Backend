def reset_password(link: str, token: str) -> str:
    return f"""
    <!DOCTYPE html>
    <html lang="pt-BR">
    <head>
        <meta charset="UTF-8">
        <title>Redefinição de Senha</title>
        <style>
            body {{
                font-family: Arial, sans-serif;
                background-color: #f5f5f5;
                margin: 0;
                padding: 0;
            }}
            .container {{
                background-color: #ffffff;
                padding: 30px;
                max-width: 600px;
                margin: 50px auto;
                border-radius: 10px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            }}
            h1 {{
                color: #333333;
                text-align: center;
            }}
            p {{
                color: #555555;
                line-height: 1.6;
            }}
            .token {{
                background-color: #f0f0f0;
                padding: 10px;
                border-radius: 5px;
                font-family: monospace;
                display: inline-block;
                margin: 10px 0;
            }}
            a.button {{
                background-color: #0205D3;
                color: #ffffff;
                padding: 14px 25px;
                text-decoration: none;
                border-radius: 6px;
                display: inline-block;
                text-align: center;
                font-weight: bold;
            }}
            a.button:hover {{
                background-color: #0103A0;
            }}
            .footer {{
                margin-top: 20px;
                font-size: 12px;
                color: #999999;
                text-align: center;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Redefinição de Senha</h1>
            <p>Você solicitou redefinir sua senha. Use o token abaixo para continuar:</p>
            <div class="token">{token}</div>
            <p>Clique no botão abaixo para acessar a página de redefinição de senha:</p>
            <p style="text-align: center;">
                <a href="{link}" class="button">Redefinir Senha</a>
            </p>
            <div class="footer">
                <p>Se você não solicitou essa ação, ignore este e-mail.</p>
            </div>
        </div>
    </body>
    </html>
    """
