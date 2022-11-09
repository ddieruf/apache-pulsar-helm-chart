{{- $extraOpts := default list .Values.pulsarEnv.extraOpts -}}

{{- if eq (include "common.tls.require-secure-inter" $) "true" -}}
  {{- $extraOpts = concat $extraOpts (include "metadata-store.zookeeper.client" . | fromJsonArray)  -}}
{{- end -}}

#!/bin/sh

# Set JAVA_HOME here to override the environment setting
# JAVA_HOME=

# default settings for starting bookkeeper

# Configuration file of settings used in bookie server
BOOKIE_CONF={{ printf "%s/%s" .Values.pulsarEnv.confPath "bookkeeper.conf" }}

# Log4j configuration file
BOOKIE_LOG_CONF={{ printf "%s/%s" .Values.pulsarEnv.confPath "log4j2.yaml" }}

# Logs location
BOOKIE_LOG_DIR={{ .Values.logPersistence.enabled | ternary .Values.logPersistence.mountPath "/pulsar/logs" }}

# Memory size options
BOOKIE_MEM=${BOOKIE_MEM:-${PULSAR_MEM:-"-Xms2g -Xmx2g -XX:MaxDirectMemorySize=2g"}}

# Garbage collection options
BOOKIE_GC=${BOOKIE_GC:-${PULSAR_GC:-"-XX:+UseG1GC -XX:MaxGCPauseMillis=10 -XX:+ParallelRefProcEnabled -XX:+UnlockExperimentalVMOptions -XX:+DoEscapeAnalysis -XX:ParallelGCThreads=32 -XX:ConcGCThreads=32 -XX:G1NewSizePercent=50 -XX:+DisableExplicitGC"}}

IS_JAVA_8=`java -version 2>&1 |grep version|grep '"1\.8'`
# java version has space, use [[ -n $PARAM ]] to judge if variable exists
if [[ -n $IS_JAVA_8 ]]; then
  BOOKIE_GC_LOG=${BOOKIE_GC_LOG:-${PULSAR_GC_LOG:-"-Xloggc:logs/pulsar_bookie_gc_%p.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=20M"}}
else
# After jdk 9, gc log param should config like this. Ignoring version less than jdk 8
  BOOKIE_GC_LOG=${BOOKIE_GC_LOG:-${PULSAR_GC_LOG:-"-Xlog:gc*:logs/pulsar_bookie_gc_%p.log:time,uptime,level,tags:filecount=10,filesize=20M"}}
fi

# Extra options to be passed to the jvm
BOOKIE_EXTRA_OPTS={{ join " " $extraOpts | quote }}

# Add extra paths to the bookkeeper classpath
BOOKIE_EXTRA_CLASSPATH={{ join ";" .Values.pulsarEnv.extraClasspath | quote }}

#Folder where the Bookie server PID file should be stored
#BOOKIE_PID_DIR=

#Wait time before forcefully kill the Bookie server instance, if the stop is not successful
#BOOKIE_STOP_TIMEOUT=

#Entry formatter class to format entries.
#ENTRY_FORMATTER_CLASS=