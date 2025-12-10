# 📧 Guia do Email Service - Mudanças e Configuração

## 🎯 **O que mudou e por quê?**

### **Problema Original:**
- A Render.com **bloqueia conexões SMTP** (portas 25, 587, 465)
- Quando o código tentava enviar email via SMTP, ocorria: `OSError: [Errno 101] Network is unreachable`
- Isso **quebrava a aplicação** e impedia criação de empresas, pedidos, etc.

### **Solução Implementada:**
1. **Resend (HTTP)** como método principal para produção
2. **SMTP** como fallback apenas para desenvolvimento local
3. **Detecção automática** de ambiente de produção
4. **Não quebra a aplicação** se o email falhar

---

## 🔧 **Variáveis de Ambiente Necessárias**

### **Opção 1: Resend (RECOMENDADO para Render.com)**

#### **1. RESEND_API_KEY** (OBRIGATÓRIO)
- **O que é:** Chave de API do Resend para autenticação
- **Como obter:**
  1. Acesse: https://resend.com
  2. Crie uma conta (grátis até 3.000 emails/mês)
  3. Vá em: **API Keys** → **Create API Key**
  4. Copie a chave (começa com `re_...`)
  5. Configure no Render.com:
     - **Environment Variables** → **Add Environment Variable**
     - Key: `RESEND_API_KEY`
     - Value: `re_xxxxxxxxxxxxx`

#### **2. RESEND_FROM_EMAIL** (OPCIONAL)
- **O que é:** Email remetente verificado no Resend
- **⚠️ IMPORTANTE:** Domínios públicos (Gmail, Yahoo, Hotmail, etc.) **NÃO podem ser verificados** no Resend
- **Como obter:**
  1. No Resend, vá em: **Domains** → **Add Domain**
  2. Adicione seu domínio próprio (ex: `fortlar.com.br`) - **NÃO pode ser gmail.com, yahoo.com, etc.**
  3. Configure os registros DNS conforme instruções do Resend
  4. Aguarde verificação (pode levar alguns minutos)
  5. OU use o domínio de teste: `onboarding@resend.dev` (funciona automaticamente, sem verificação)
  6. Configure no Render.com:
     - Key: `RESEND_FROM_EMAIL`
     - Value: `noreply@fortlar.com.br` (ou seu email verificado)

**Nota:** 
- Se não configurar `RESEND_FROM_EMAIL`, o sistema usa `MAIL_FROM` do `envs.py` como fallback
- Se o email configurado usar domínio público (gmail.com, etc.), o sistema **automaticamente** usa `onboarding@resend.dev`

---

### **Opção 2: SMTP (Apenas para desenvolvimento local)**

Essas variáveis já estão no seu `envs.py` e funcionam **apenas localmente**:

```python
MAIL_USERNAME='sitefortlar@gmail.com'
MAIL_PASSWORD='odil hbbe zsfp xpdy'  # App Password do Gmail
MAIL_FROM="sitefortlar@gmail.com"
MAIL_PORT=587
MAIL_SERVER="smtp.gmail.com"
```

**⚠️ IMPORTANTE:** Essas variáveis **NÃO funcionam na Render.com** porque o SMTP é bloqueado.

---

## 📋 **Como o Sistema Funciona Agora**

### **Fluxo de Decisão:**

```
1. EmailService inicia
   ↓
2. Verifica se Resend está instalado E se RESEND_API_KEY existe
   ↓
   ├─ SIM → Usa Resend (HTTP) ✅
   │         └─ Funciona na Render.com
   │
   └─ NÃO → Usa SMTP (fallback) ⚠️
            └─ Verifica se está em produção (Render.com)
               ├─ SIM → Bloqueia e retorna None (não quebra app)
               └─ NÃO → Tenta enviar via SMTP (desenvolvimento local)
```

### **Comportamento em Produção (Render.com):**

1. **Se `RESEND_API_KEY` estiver configurado:**
   - ✅ Envia emails normalmente via Resend
   - ✅ Logs: `✅ Email enviado via Resend para...`

2. **Se `RESEND_API_KEY` NÃO estiver configurado:**
   - ⚠️ Detecta que está na Render
   - ⚠️ Bloqueia tentativa de SMTP
   - ⚠️ Logs: `⚠️ Tentativa de enviar email via SMTP na Render (bloqueado)`
   - ✅ **A aplicação continua funcionando** (não quebra)
   - ✅ Tokens/empresas/pedidos são salvos normalmente

### **Comportamento em Desenvolvimento Local:**

1. **Se `RESEND_API_KEY` estiver configurado:**
   - ✅ Usa Resend (mesmo comportamento da produção)

2. **Se `RESEND_API_KEY` NÃO estiver configurado:**
   - ✅ Usa SMTP com as credenciais do `envs.py`
   - ✅ Funciona normalmente com Gmail

---

## 🚀 **Passo a Passo para Configurar no Render.com**

### **1. Criar conta no Resend:**
```
1. Acesse: https://resend.com
2. Clique em "Sign Up"
3. Crie sua conta (pode usar GitHub)
4. Confirme seu email
```

### **2. Obter API Key:**
```
1. No dashboard do Resend, vá em: "API Keys"
2. Clique em: "Create API Key"
3. Dê um nome (ex: "Render Production")
4. Copie a chave (ela só aparece uma vez!)
```

### **3. Verificar Domínio Próprio (Opcional, mas recomendado para produção):**

**⚠️ IMPORTANTE:** Você **NÃO pode verificar domínios públicos** como:
- ❌ gmail.com
- ❌ yahoo.com  
- ❌ hotmail.com
- ❌ outlook.com
- ❌ etc.

**Você SÓ pode verificar domínios próprios** como:
- ✅ fortlar.com.br
- ✅ seu-dominio.com
- ✅ exemplo.com.br

**Passo a passo para verificar seu domínio próprio:**

```
1. Acesse: https://resend.com/domains
2. Clique em: "Add Domain"
3. Digite seu domínio próprio: fortlar.com.br (NÃO use gmail.com!)
4. O Resend mostrará os registros DNS que você precisa adicionar:
   - Registro SPF (TXT)
   - Registro DKIM (TXT) 
   - Registro DMARC (TXT) - opcional
5. Acesse o painel do seu provedor de domínio (onde você comprou fortlar.com.br)
6. Adicione os registros DNS conforme as instruções do Resend
7. Volte ao Resend e clique em "Verify"
8. Aguarde verificação (pode levar alguns minutos até 24 horas)
9. Quando verificado, você verá um ✅ verde
10. Agora você pode usar: noreply@fortlar.com.br, contato@fortlar.com.br, etc.
```

**Alternativa (para testes rápidos):**
- Use `onboarding@resend.dev` - funciona automaticamente, sem verificação
- O código já detecta domínios públicos e usa este email automaticamente

### **4. Configurar no Render.com:**
```
1. Acesse seu serviço no Render.com
2. Vá em: "Environment"
3. Clique em: "Add Environment Variable"
4. Adicione:
   - Key: RESEND_API_KEY
   - Value: re_xxxxxxxxxxxxx (sua chave)
5. (Opcional) Adicione:
   - Key: RESEND_FROM_EMAIL
   - Value: noreply@fortlar.com.br (ou seu email verificado)
6. Salve as mudanças
7. O Render fará redeploy automaticamente
```

---

## 📊 **Comparação: SMTP vs Resend**

| Característica | SMTP | Resend |
|---------------|------|--------|
| **Funciona na Render.com** | ❌ Bloqueado | ✅ Funciona |
| **Funciona localmente** | ✅ Sim | ✅ Sim |
| **Tipo de conexão** | TCP (portas 25/587/465) | HTTP/HTTPS |
| **Configuração** | Complexa (DNS, portas) | Simples (API Key) |
| **Limite gratuito** | Depende do provedor | 3.000 emails/mês |
| **Rastreamento** | Não | ✅ Sim (dashboard) |
| **Tempo de entrega** | Variável | Rápido |

---

## 🔍 **Como Verificar se Está Funcionando**

### **1. Verificar Logs no Render.com:**
```
✅ EmailService inicializado com Resend (HTTP) - From: noreply@fortlar.com.br
✅ Email enviado via Resend para usuario@email.com (ID: abc123)
```

### **2. Verificar no Dashboard do Resend:**
```
1. Acesse: https://resend.com/emails
2. Veja todos os emails enviados
3. Veja status (delivered, bounced, etc.)
```

### **3. Testar Localmente:**
```bash
# Com RESEND_API_KEY configurado no .env
python -c "from app.application.service.email_service import EmailService; es = EmailService(); print('✅ Resend configurado' if es.use_resend else '⚠️ Usando SMTP')"
```

---

## ⚠️ **Troubleshooting**

### **Problema: "Email não enviado" mas app não quebra**
**Solução:** Configure `RESEND_API_KEY` no Render.com

### **Problema: "Invalid API Key"**
**Solução:** Verifique se copiou a chave completa (começa com `re_`)

### **Problema: "Domain not verified"**
**Solução:** 
- Use `onboarding@resend.dev` para testes
- OU verifique seu domínio no Resend

### **Problema: Emails indo para spam**
**Solução:** 
- Verifique seu domínio no Resend
- Configure SPF/DKIM/DMARC conforme instruções

---

## 📝 **Resumo das Mudanças no Código**

### **1. email_service.py:**
- ✅ Detecta automaticamente se está em produção
- ✅ Usa Resend se `RESEND_API_KEY` estiver configurado
- ✅ Bloqueia SMTP em produção (não tenta conectar)
- ✅ Retorna `None` em vez de quebrar a aplicação
- ✅ Logs informativos para debug

### **2. Use Cases (create_company, forgot, etc.):**
- ✅ Salvam dados **ANTES** de tentar enviar email
- ✅ Se email falhar, apenas loga aviso (não quebra)
- ✅ Usuário pode solicitar reenvio depois

---

## 🎯 **Próximos Passos**

1. ✅ Criar conta no Resend
2. ✅ Obter API Key
3. ✅ Configurar `RESEND_API_KEY` no Render.com
4. ✅ (Opcional) Verificar domínio no Resend
5. ✅ Testar envio de email
6. ✅ Verificar logs e dashboard do Resend

---

## 💡 **Dica Final**

**Para desenvolvimento local**, você pode:
- Usar Resend (mesmo da produção) - recomendado
- OU usar SMTP (Gmail) - funciona localmente

**Para produção (Render.com)**, você **DEVE** usar Resend, pois SMTP é bloqueado.

---

**Qualquer dúvida, consulte os logs da aplicação ou o dashboard do Resend!** 🚀

