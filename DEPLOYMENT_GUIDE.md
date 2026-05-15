# 🚀 Guia de Desenvolvimento e Deploy - Click Prestare

Este guia contém as soluções para os problemas de sincronização entre Localhost e Produção (Vercel/Railway) e as instruções para rodar o ambiente local.

## 🛠 Ambiente Local (Localhost)

Para rodar o ecossistema completo localmente, siga os comandos abaixo:

1.  **API Principal (NestJS)**:
    *   Pasta: `click-cond-web`
    *   Comando: `npx nx serve api`
    *   URL: `http://localhost:3000/api`

2.  **Sistema Web Portaria (Angular)**:
    *   Pasta: `click-cond-web`
    *   Comando: `npx nx serve portaria-web`
    *   URL: `http://localhost:4200/`

3.  **App Click (Flutter)**:
    *   Pasta: `click-cond-app/click-cond-app`
    *   Caminho do SDK: `C:\Users\vinic\Desktop\flutter\bin\flutter.bat`
    *   Comando: `C:\Users\vinic\Desktop\flutter\bin\flutter.bat run -d chrome`
    *   *Nota: O caminho do SDK foi salvo em `.antigravity_config.json`.*

4.  **API Legada/Utilitários (Porta 3003)**:
    *   Pasta: `click-cond-api/click-cond-api`
    *   Comando: `npm run dev`
    *   URL: `http://localhost:3003`

---

## 1. Vercel não atualiza com as novidades
**Problema:** Você faz alterações no código, mas o site no Vercel continua mostrando a versão antiga.
**Causa:** O Vercel está configurado para monitorar a branch `main`, mas o desenvolvimento está ocorrendo na branch `master`.
**Solução:**
Sempre que quiser subir as novidades para o Vercel, você deve mesclar a `master` na `main`:
```bash
git checkout main
git pull origin main
git merge master
git push origin main
git checkout master
```

## 2. Estrutura de Monorepo no Vercel
**Problema:** O Vercel não encontra o projeto Angular ou as dependências.
**Solução:** 
- Foi adicionado um `package.json` na **raiz** do repositório para delegar o build para a pasta `click-cond-web`.
- Nas configurações do Vercel (**Settings > General**), o **Root Directory** deve ser `click-cond-web`.
- O comando de build deve ser: `npx nx build portaria-web`.
- A pasta de saída (Output Directory) deve ser: `dist/apps/portaria-web/browser`.

## 3. Imagens não aparecem no App Mobile
**Problema:** O sistema web mostra imagens, mas o App mostra um ícone cinza.
**Causa:** O campo `imagem` no banco de dados está nulo, e apenas a Web tinha um fallback (imagem padrão).
**Solução:**
- O backend (`AreasSociaisService.ts`) agora retorna uma URL padrão do Unsplash se o campo for nulo.
- O App (`cell_area_social.dart`) também possui um link de fallback interno para garantir que nunca fique vazio.

## 4. Sincronização de Banco de Dados
**Importante:** A API em produção (Railway) usa o banco de dados oficial. Se você criar tabelas novas ou mudar o schema, lembre-se de rodar:
```bash
npx prisma generate
npx prisma db push
```
*(Verifique se o DATABASE_URL no Railway está correto antes de rodar comandos de escrita)*.
