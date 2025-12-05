# Solução de Problemas (Troubleshooting)

## Erro: Postgres falha ao iniciar com "could not open directory pg_notify"

### Sintoma
Ao tentar subir os containers com `docker-compose up -d`, o container do Postgres fica reiniciando (`Restarting`) ou marcado como `unhealthy`.

Ao verificar os logs com `docker logs evolution_postgres`, aparece o seguinte erro repetidamente:
```
FATAL:  could not open directory "pg_notify": No such file or directory
LOG:  database system is shut down
```

### Causa
Este erro ocorre quando os arquivos de dados do PostgreSQL, que estão salvos localmente na pasta `./data/postgres`, foram corrompidos. Isso geralmente acontece se o computador desligou inesperadamente, se o Docker travou, ou se houve problemas de permissão na pasta local do Windows.

Como o `docker-compose.yml` usa um volume mapeado localmente (bind mount):
```yaml
volumes:
  - ./data/postgres:/var/lib/postgresql/data
```
O comando `docker-compose down -v` **NÃO** resolve, pois ele limpa apenas volumes internos do Docker, e não pastas locais do seu computador.

### Solução
É necessário apagar manualmente a pasta corrompida para que o Postgres possa recriá-la do zero na próxima inicialização.

**Passo a passo:**

1.  Pare os containers:
    ```powershell
    docker-compose down
    ```

2.  Remova a pasta de dados corrompida:
    ```powershell
    Remove-Item -Path ".\data\postgres" -Recurse -Force
    ```
    *(Nota: Isso apagará todos os dados do banco. Em ambiente de produção, seria necessário restaurar um backup).*

3.  Inicie os containers novamente:
    ```powershell
    docker-compose up -d
    ```

4.  Verifique se o Postgres subiu corretamente (status `healthy`):
    ```powershell
    docker-compose ps
    ```
