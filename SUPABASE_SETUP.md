# Configuração do Supabase para Upload de Imagens

Este documento descreve como configurar o Supabase Storage para o endpoint de upload de planilha de imagens.

## Variáveis de Ambiente

Adicione as seguintes variáveis ao seu arquivo `.env`:

```env
# URL do projeto Supabase (ex: https://xxxxx.supabase.co)
SUPABASE_URL=https://xxxxx.supabase.co

# Chave de API do Supabase
# Recomendado: Use a Service Role Key para ter permissões completas no Storage
SUPABASE_KEY=sua_chave_api_aqui

# Nome do bucket no Supabase Storage onde as imagens serão armazenadas
# O bucket deve estar configurado como público para gerar links públicos
SUPABASE_BUCKET=products
```

## Como Obter as Credenciais

### Para Upload no Storage (Recomendado - Nova API)

1. Acesse o painel do Supabase: https://app.supabase.com
2. Selecione seu projeto
3. Vá em **Settings** > **API Keys**
4. Na seção **"Secret keys"**, clique em **"+ New secret key"**
5. Dê um nome descritivo (ex: `backend_storage` ou `api_upload`)
6. **IMPORTANTE**: Copie a chave imediatamente, pois ela só será mostrada uma vez
7. Use esta **Secret Key** como `SUPABASE_KEY` no arquivo `.env`

**Formato da chave**: Deve começar com `sb_secret_` seguido de caracteres alfanuméricos

### Alternativa: Legacy Service Role Key

Se você ainda estiver usando o sistema antigo:
1. Vá em **Settings** > **API**
2. Copie a **Service Role Key** (não a Anon Key)
3. Esta chave geralmente começa com `eyJ...` (formato JWT)

**Nota**: O Supabase está migrando para o novo sistema de API Keys. Use as **Secret Keys** do novo sistema quando possível.

## Configuração do Bucket

1. No painel do Supabase, vá em **Storage**
2. Crie um novo bucket chamado `products` (ou o nome que você configurou em SUPABASE_BUCKET)
3. **IMPORTANTE**: Marque o bucket como **Público** para que os links gerados sejam acessíveis publicamente
4. Configure as políticas de acesso conforme necessário

## Exemplo de Configuração Completa

```env
SUPABASE_URL=https://abcdefghijklmnop.supabase.co
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoic2VydmljZV9yb2xlIiwiaWF0IjoxNjE2MjM5MDIyfQ.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
SUPABASE_BUCKET=products
```

## Formato da Planilha

A planilha Excel deve conter as seguintes colunas:

- **codigo**: Código do produto (será usado como nome do arquivo, ex: `123.jpg`)
- **nome**: Nome do produto
- **imagem_url**: URL do Google Drive da imagem

## Formato dos Links do Google Drive Suportados

O sistema suporta os seguintes formatos de links do Google Drive:

- `https://drive.google.com/file/d/FILE_ID/view?usp=sharing`
- `https://drive.google.com/open?id=FILE_ID`
- `https://drive.google.com/uc?id=FILE_ID`
- `https://drive.google.com/file/d/FILE_ID/edit`

## Resultado

Após o processamento, a planilha retornada terá uma coluna adicional:

- **imagem_supabase**: Link público da imagem no Supabase Storage no formato:
  `https://<PROJECT_ID>.supabase.co/storage/v1/object/public/products/produtos/<codigo>.jpg`

**Nota:** As imagens são armazenadas na pasta `produtos/` dentro do bucket para melhor organização.

## Configuração do SDK

O código utiliza o SDK oficial do Supabase (`supabase-py`) conforme a [documentação oficial](https://supabase.com/docs/reference/python/storage-upload):

**Formato do upload:**
```python
supabase.storage.from_('bucket_name').upload('file_path', file, options)
```

**Opções configuradas:**
- `'upsert': 'true'` - Permite sobrescrever arquivos existentes (string)
- `'content-type': 'image/jpeg'` - Tipo MIME explícito (com hífen)

**Path format**: As imagens são armazenadas no formato `produtos/<codigo>.jpg` seguindo o padrão `folder/subfolder/filename.ext` recomendado pela documentação do Supabase.

**Nota sobre overwriting**: A documentação do Supabase recomenda evitar sobrescrever arquivos quando possível, pois o CDN pode levar algum tempo para propagar as mudanças. No entanto, configuramos `upsert: 'true'` para permitir atualizações quando necessário.

## Políticas RLS (Row Level Security)

**IMPORTANTE**: Se o bucket for privado, certifique-se de configurar as políticas RLS no Supabase para permitir:
- **INSERT**: Para fazer upload de novos arquivos
- **UPDATE**: Para sobrescrever arquivos existentes (quando upsert=true)
- **SELECT**: Para acessar os arquivos (se necessário)

Para buckets públicos, as políticas são menos restritivas, mas ainda recomendamos configurá-las adequadamente.

