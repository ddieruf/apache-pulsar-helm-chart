{{- $extraOpts := default list .Values.pulsarEnv.extraOpts -}}

{{- if eq (include "common.tls.require-secure-inter" $) "true" -}}
  {{/* Configure the zookeeper client to be secure */}}
  {{- $extraOpts = append $extraOpts "-Dzookeeper.client.secure=true" -}}
  {{- $extraOpts = append $extraOpts "-Dzookeeper.clientCnxnSocket=org.apache.zookeeper.ClientCnxnSocketNetty" -}}

  {{- $extraOpts = append $extraOpts "-Dzookeeper.ssl.trustStore.type=JKS" -}}
  {{- $extraOpts = append $extraOpts "-Dzookeeper.ssl.trustStore.location=/pulsar/jks/truststore.jks" -}}
  {{- $extraOpts = append $extraOpts "-Dzookeeper.ssl.trustStore.passwordPath=/pulsar/jks/jks-password" -}}

  {{- $extraOpts = append $extraOpts "-Dzookeeper.ssl.keyStore.type=JKS" -}}
  {{- $extraOpts = append $extraOpts "-Dzookeeper.ssl.keyStore.location=/pulsar/jks/keystore.jks" -}}
  {{- $extraOpts = append $extraOpts "-Dzookeeper.ssl.keyStore.passwordPath=/pulsar/jks/jks-password" -}}
{{- end -}}

PULSAR_EXTRA_CLASSPATH={{ join ";" .Values.pulsarEnv.extraClasspath | quote }}
PULSAR_EXTRA_OPTS={{ join " " $extraOpts | quote }}
PULSAR_GC={{ join " " .Values.pulsarEnv.gc | quote }}
PULSAR_MEM={{ join " " .Values.pulsarEnv.mem | quote }}
PULSAR_LOG_DIR={{ .Values.logPersistence.mountPath }}
PULSAR_ZK_CONF={{ printf "%s/%s" .Values.pulsarEnv.confPath "zookeeper.conf" }}
PULSAR_STOP_TIMEOUT={{.Values.pulsarEnv.stopTimeout}}
ZOO_LOG_LEVEL={{ default "error" .Values.pulsarEnv.loggingLevels.root }}

# Garbage collection log.
IS_JAVA_8=`java -version 2>&1 |grep version|grep '"1\.8'`
# java version has space, use [[ -n $PARAM ]] to judge if variable exists
if [[ -n $IS_JAVA_8 ]]; then
  PULSAR_GC_LOG=${PULSAR_GC_LOG:-"-Xloggc:logs/pulsar_gc_%p.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=20M"}
else
# After jdk 9, gc log param should config like this. Ignoring version less than jdk 8
  PULSAR_GC_LOG=${PULSAR_GC_LOG:-"-Xlog:gc*:logs/pulsar_gc_%p.log:time,uptime:filecount=10,filesize=20M"}
fi