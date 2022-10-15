{{- $extraOpts := default list .Values.pulsarEnv.extraOpts -}}

{{- if eq (include "common.tls.require-secure-inter" $) "true" -}}
  {{- $extraOpts = append $extraOpts "-Djavax.net.ssl.trustStorePassword=/pulsar/jks/jks-password" -}}
  {{- $extraOpts = append $extraOpts "-Djavax.net.ssl.keyStorePassword=/pulsar/jks/jks-password" -}}
  {{- $extraOpts = append $extraOpts "-Djavax.net.ssl.keyStore=/pulsar/jks/keystore.jks" -}}
  {{- $extraOpts = append $extraOpts "-Djavax.net.ssl.trustStore=/pulsar/jks/truststore.jks" -}}
{{- end -}}

PULSAR_EXTRA_CLASSPATH={{ join ";" .Values.pulsarEnv.extraClasspath | quote }}
PULSAR_EXTRA_OPTS={{ join " " $extraOpts | quote }}
PULSAR_GC={{ join " " .Values.pulsarEnv.gc | quote }}
PULSAR_MEM={{ join " " .Values.pulsarEnv.mem | quote }}
PULSAR_LOG_DIR={{ .Values.logPersistence.mountPath }}
PULSAR_ZK_CONF={{ printf "%s/%s" .Values.pulsarEnv.confPath "zookeeper.conf" }}
PULSAR_GLOBAL_ZK_CONF={{ printf "%s/%s" .Values.pulsarEnv.confPath "global_zookeeper.conf" }}
PULSAR_STOP_TIMEOUT={{.Values.pulsarEnv.stopTimeout}}

# Garbage collection log.
IS_JAVA_8=`java -version 2>&1 |grep version|grep '"1\.8'`
# java version has space, use [[ -n $PARAM ]] to judge if variable exists
if [[ -n $IS_JAVA_8 ]]; then
  PULSAR_GC_LOG=${PULSAR_GC_LOG:-"-Xloggc:logs/pulsar_gc_%p.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=20M"}
else
# After jdk 9, gc log param should config like this. Ignoring version less than jdk 8
  PULSAR_GC_LOG=${PULSAR_GC_LOG:-"-Xlog:gc*:logs/pulsar_gc_%p.log:time,uptime:filecount=10,filesize=20M"}
fi