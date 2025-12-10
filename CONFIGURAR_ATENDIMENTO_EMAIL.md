# 📧 Como Configurar atendimento@fortlar.com.br

## 🎯 Objetivo
Configurar o email `atendimento@fortlar.com.br` como remetente dos emails enviados pelo sistema.

---

## ⚠️ PRÉ-REQUISITO OBRIGATÓRIO

**Você PRECISA verificar o domínio `fortlar.com.br` no Resend antes de usar este email!**

Se o domínio não estiver verificado, o Resend vai rejeitar o envio com erro:
```
The fortlar.com.br domain is not verified. Please, add and verify your domain on https://resend.com/domains
```

---

## 📋 Passo a Passo Completo

### **1. Verificar o Domínio fortlar.com.br no Resend**

#### **1.1. Acessar o Resend**
1. Acesse: https://resend.com
2. Faça login na sua conta
3. Vá em: **Domains** (no menu lateral)

#### **1.2. Adicionar o Domínio**
1. Clique em: **"Add Domain"**
2. Digite: `fortlar.com.br` (sem www, sem http)
3. Clique em: **"Add"**

#### **1.3. Obter os Registros DNS**
O Resend vai mostrar uma página com os registros DNS que você precisa adicionar:

**Exemplo de registros que o Resend vai mostrar:**

```
Tipo: TXT
Nome: @ (ou fortlar.com.br)
Valor: v=spf1 include:resend.com ~all

Tipo: TXT  
Nome: resend._domainkey (ou resend._domainkey.fortlar.com.br)
Valor: [uma string longa fornecida pelo Resend]

Tipo: TXT (opcional - DMARC)
Nome: _dmarc
Valor: v=DMARC1; p=none;
```

#### **1.4. Adicionar os Registros DNS no seu Provedor de Domínio**

**Onde você comprou o domínio fortlar.com.br?**
- Registro.br
- GoDaddy
- Namecheap
- Cloudflare
- Outro provedor

**Passos gerais (podem variar por provedor):**

1. Acesse o painel do seu provedor de domínio
2. Procure por: **DNS**, **Zona DNS**, **Gerenciamento DNS**, **DNS Records**
3. Adicione os registros TXT que o Resend forneceu:
   - **SPF**: Registro TXT com o valor do SPF
   - **DKIM**: Registro TXT com o nome `resend._domainkey` e o valor fornecido
   - **DMARC**: (Opcional) Registro TXT com nome `_dmarc`
4. Salve as alterações

**⚠️ IMPORTANTE:**
- A propagação DNS pode levar de alguns minutos até 24 horas
- Aguarde alguns minutos antes de verificar no Resend

#### **1.5. Verificar no Resend**
1. Volte para o Resend (https://resend.com/domains)
2. Clique em: **"Verify"** ao lado do domínio `fortlar.com.br`
3. Aguarde alguns minutos
4. Quando verificado, você verá um ✅ verde ao lado do domínio

**Status possíveis:**
- ✅ **Verified** - Domínio verificado e pronto para uso
- ⏳ **Pending** - Aguardando verificação (pode levar até 24h)
- ❌ **Failed** - Erro na verificação (verifique os registros DNS)

---

### **2. Configurar no Render.com**

Após verificar o domínio no Resend:

1. Acesse seu serviço no Render.com
2. Vá em: **Environment** (no menu lateral)
3. Procure pela variável: `RESEND_FROM_EMAIL`
4. Se não existir, clique em: **"Add Environment Variable"**
5. Configure:
   - **Key:** `RESEND_FROM_EMAIL`
   - **Value:** `atendimento@fortlar.com.br`
6. Clique em: **"Save Changes"**
7. O Render fará redeploy automaticamente

---

### **3. Verificar se Está Funcionando**

#### **3.1. Verificar Logs no Render.com**

Após o redeploy, verifique os logs. Você deve ver:

```
✅ EmailService inicializado com Resend (HTTP) - From: atendimento@fortlar.com.br
```

Se aparecer:
```
⚠️ Email 'from' configurado (atendimento@fortlar.com.br) usa domínio público não verificado...
```

Significa que o domínio ainda não está verificado no Resend.

#### **3.2. Testar Envio de Email**

Teste enviando um email (ex: reenvio de token). Verifique os logs:

**Sucesso:**
```
✅ Email enviado via Resend para usuario@email.com (ID: abc123)
```

**Erro (domínio não verificado):**
```
❌ Erro ao enviar email via Resend: The fortlar.com.br domain is not verified...
```

#### **3.3. Verificar no Dashboard do Resend**

1. Acesse: https://resend.com/emails
2. Veja os emails enviados
3. Verifique o campo "From" - deve mostrar `atendimento@fortlar.com.br`

---

## 🔍 Troubleshooting

### **Problema: "Domain is not verified"**

**Causa:** O domínio `fortlar.com.br` não está verificado no Resend.

**Solução:**
1. Verifique se adicionou os registros DNS corretamente
2. Aguarde a propagação DNS (pode levar até 24h)
3. Tente verificar novamente no Resend
4. Verifique se os registros DNS estão corretos (sem espaços extras, valores completos)

### **Problema: "DNS records not found"**

**Causa:** Os registros DNS ainda não foram propagados.

**Solução:**
1. Aguarde mais alguns minutos (propagação DNS pode levar tempo)
2. Verifique se os registros foram salvos corretamente no seu provedor de DNS
3. Use uma ferramenta como https://mxtoolbox.com para verificar os registros DNS

### **Problema: Email ainda usando onboarding@resend.dev**

**Causa:** O domínio não está verificado OU a variável `RESEND_FROM_EMAIL` não está configurada.

**Solução:**
1. Verifique se o domínio está verificado no Resend (✅ verde)
2. Verifique se `RESEND_FROM_EMAIL=atendimento@fortlar.com.br` está configurado no Render.com
3. Faça redeploy no Render.com

---

## ✅ Checklist Final

Antes de considerar configurado, verifique:

- [ ] Domínio `fortlar.com.br` está verificado no Resend (✅ verde)
- [ ] Variável `RESEND_FROM_EMAIL=atendimento@fortlar.com.br` configurada no Render.com
- [ ] Logs mostram: `✅ EmailService inicializado com Resend (HTTP) - From: atendimento@fortlar.com.br`
- [ ] Teste de envio de email funcionou
- [ ] Dashboard do Resend mostra emails enviados com `atendimento@fortlar.com.br`

---

## 💡 Dica

Se precisar testar rapidamente enquanto verifica o domínio, o sistema automaticamente usa `onboarding@resend.dev` como fallback. Mas para produção, é recomendado usar seu próprio domínio verificado.

---

**Precisa de ajuda?** Consulte os logs do Render.com ou o dashboard do Resend para mais detalhes.


