#!/usr/bin/bash
set -x

DATA_AAAAMMDD=`date '+%Y%m%d'`
HORA_HHMMSS=`date '+%H%M%S'`
DIR_SCRIPTS=/scripts
DIR_LOG=/log
ARQ_LOG=deploy_app_java_${DATA_AAAAMMDD}_${HORA_HHMMSS}.log
DIR_FTP_APP=/ftp_app
DIR_APP=/app
ARQ_APP=myapp.jar

echo "##########################################################" >> ${DIR_LOG}/${ARQ_LOG}
echo "       INICANDO CHECAGEM DE ARQUIVO                      #" >> ${DIR_LOG}/${ARQ_LOG}
echo "##########################################################" >> ${DIR_LOG}/${ARQ_LOG}

ls -ltr ${DIR_FTP_APP}/${ARQ_APP} >> ${DIR_LOG}/${ARQ_LOG}

if [ $? -ne 0 ]
   then
      echo "##############################################" >> ${DIR_LOG}/${ARQ_LOG}
      echo "#         SEM ARQUIVO PARA DEPLOY            #" >> ${DIR_LOG}/${ARQ_LOG}
      echo "#          RETORNO_PROCESSO = 2              #" >> ${DIR_LOG}/${ARQ_LOG}
      echo "##############################################" >> ${DIR_LOG}/${ARQ_LOG}
      exit 2
   else
      echo "##############################################" >> ${DIR_LOG}/${ARQ_LOG}
      echo "#      NOVO ARQUIVO .JAR ENCONTRADO          #" >> ${DIR_LOG}/${ARQ_LOG}
      echo "##############################################" >> ${DIR_LOG}/${ARQ_LOG}
      lsof | grep ${ARQ_APP} >> ${DIR_LOG}/${ARQ_LOG}
      if [ $? -eq 0 ]
   then
      echo "##############################################" >> ${DIR_LOG}/${ARQ_LOG}
      echo "#      ARQUIVO .JAR EM TRANSMISSAO           #" >> ${DIR_LOG}/${ARQ_LOG}
      echo "##############################################" >> ${DIR_LOG}/${ARQ_LOG}
      while true; do lsof | grep ${ARQ_APP}
       if [ $? -eq 0 ]
        then 
         echo "##############################################" >> ${DIR_LOG}/${ARQ_LOG}
	 echo "#      ARQUIVO .JAR EM TRANSMISSAO           #" >> ${DIR_LOG}/${ARQ_LOG}
	 echo "#      HORA $HORA_HHMMSS                     #" >> ${DIR_LOG}/${ARQ_LOG}
         echo "##############################################" >> ${DIR_LOG}/${ARQ_LOG}
         sleep 30
	else 
         echo "##############################################" >> ${DIR_LOG}/${ARQ_LOG}
	 echo "#      TRANSMISSAO .JAR FINALIZADA           #" >> ${DIR_LOG}/${ARQ_LOG}
         echo "#      HORA $HORA_HHMMSS                     #" >> ${DIR_LOG}/${ARQ_LOG}
         echo "##############################################" >> ${DIR_LOG}/${ARQ_LOG}
	 break
        fi
      done
    fi
fi

echo "##########################################################" >> ${DIR_LOG}/${ARQ_LOG}
echo "       CHECAGEM DE ARQUIVO FINALIZADA                    #" >> ${DIR_LOG}/${ARQ_LOG}
echo "##########################################################" >> ${DIR_LOG}/${ARQ_LOG}

echo "##########################################################" >> ${DIR_LOG}/${ARQ_LOG}
echo "       FINALIZANDO PROCESSO DA APLICACAO                 #" >> ${DIR_LOG}/${ARQ_LOG}
echo "##########################################################" >> ${DIR_LOG}/${ARQ_LOG}

PID_JAVA=`ps -aux | grep myapp | grep -v grep | awk '{print $2}'`
echo ${PID_JAVA} >> ${DIR_LOG}/${ARQ_LOG}

kill ${PID_JAVA} >> ${DIR_LOG}/${ARQ_LOG}
sleep 20
ps -aux | grep ${PID_JAVA} | grep -v grep >> ${DIR_LOG}/${ARQ_LOG}
  if [ $? -ne 0 ]
   then
    echo "##################################################" >> ${DIR_LOG}/${ARQ_LOG}
    echo "            APLICACAO FINALIZADA                 #" >> ${DIR_LOG}/${ARQ_LOG}
    echo "##################################################" >> ${DIR_LOG}/${ARQ_LOG}
   else
    kill -9 ${PID_JAVA} >> ${DIR_LOG}/${ARQ_LOG}
    echo "##################################################" >> ${DIR_LOG}/${ARQ_LOG}
    echo "      APLICACAO FINALIZADA DE FORMA FORCADA      #" >> ${DIR_LOG}/${ARQ_LOG}
    echo "##################################################" >> ${DIR_LOG}/${ARQ_LOG}
   fi
   
echo "##########################################################" >> ${DIR_LOG}/${ARQ_LOG}
echo "       REALIZANDO DEPLOY APLICACAO                       #" >> ${DIR_LOG}/${ARQ_LOG}
echo "##########################################################" >> ${DIR_LOG}/${ARQ_LOG}
		
cp -rf ${DIR_FTP_APP}/${ARQ_APP} ${DIR_APP}

echo "##########################################################" >> ${DIR_LOG}/${ARQ_LOG}
echo "             INICIALIZANDO A APLICACAO                   #" >> ${DIR_LOG}/${ARQ_LOG}
echo "##########################################################" >> ${DIR_LOG}/${ARQ_LOG}

java -jar ${DIR_APP}/${ARQ_APP} >> ${DIR_LOG}/${ARQ_LOG}
sleep 20
PID_JAVA=`ps -aux | grep myapp | grep -v grep | awk '{print $2}'`
echo ${PID_JAVA} >> ${DIR_LOG}/${ARQ_LOG}
 if [ $? -ne 0 ]
  then
   echo "##################################################" >> ${DIR_LOG}/${ARQ_LOG}
   echo "      ERRO NA INICIALIZACAO DA APLICACAO         #" >> ${DIR_LOG}/${ARQ_LOG}
   echo "            SUPORTE SERA COMUNICADO              #" >> ${DIR_LOG}/${ARQ_LOG}
   echo "##################################################" >> ${DIR_LOG}/${ARQ_LOG}
   mailx -s "Erro no deploy da aplicacao JAVA" -r suporte@domain.com.br suporte@domain.com.br < ${DIR_LOG}/${ARQ_LOG}
   exit 10
  else
   echo "##################################################" >> ${DIR_LOG}/${ARQ_LOG}
   echo "      APLICACAO INICIALIZADA COM SUCESSO         #" >> ${DIR_LOG}/${ARQ_LOG}
   echo "             DEPLOY FINALIZADO                   #" >> ${DIR_LOG}/${ARQ_LOG}
   echo "##################################################" >> ${DIR_LOG}/${ARQ_LOG}
   mailx -s "Deploy APP JAVA finalizado com sucesso" -r suporte@domain.com.br suporte@domain.com.br < ${DIR_LOG}/${ARQ_LOG}
   rm -rf ${DIR_FTP_APP}/${ARQ_APP}
   exit 0
 fi
