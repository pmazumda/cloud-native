def getIPandPort(String svcname){
    container('compilebox'){
        String  port = sh script: """kubectl get svc -o=jsonpath='{.items[?(@.metadata.name=="${svcname}")].spec.ports[0].port}' -n ${env.NAMESPACE}""", returnStdout: true
        sleep time: 60, unit: "SECONDS"
        String  serviceip = sh script: """
		set +x
        while(true)
        do
        sip=`kubectl get svc -o=jsonpath='{.items[?(@.metadata.name=="${svcname}")].status.loadBalancer.ingress[0].ip}' -n ${env.NAMESPACE}`
        if [ -z \$sip ]
        then
        echo "ip field is empty"
        sleep 5
        else
        echo \$sip
        break
        fi
        done
		""", returnStdout: true
        return [Port:port, SERVICEIP:serviceip]
    }
}
