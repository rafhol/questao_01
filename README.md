

A solução apresentada consiste em se ter um NFS criado entre o servidor de FTP, que receberá o pacote enviado pela fábrica e o servidor onde a aplicação java é executada. Com esse NFS montado, foi criado o script "deploy_app_java.sh", que é executado no servidor da aplicação. O mesmo monitora o recebimento do arquivo .jar no caminho em questão e, assim que verifica a presença do arquivo no caminho, testa se o mesmo ainda está em uso, em caso positivo, aguarda 30 segundos. Quando é verificado que o arquivo não está mais em uso, é efetuado kill no processo da app java em execução, realizado o deploy da nova versão para o caminho da aplicação e realizado o start da mesma através do comando "java -jar". Ao final do script, ou caso ocorra algum erro durante a execução do mesmo, é enviado um e-mail para a equipe responsável verificar. A execução do script será agendada via crontab diariamente, com intervalo sugerido a cada hora.

Foi escolhida essa solução, devido a dificuldade de se saber em que momento do dia será enviada a atualização e, para realizar o deploy o mais rápido possível.


Variáveis:

DIR_SCRIPTS= "diretório do script"

DIR_LOG= "diretório a ser gravado o  log"

DIR_FTP_APP= "diretório de recebimento da versão para deploy"

DIR_APP= "diretório da aplicação"

ARQ_APP= "nome do arquivo .jar"

