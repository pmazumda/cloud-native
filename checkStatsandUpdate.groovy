def deleteResources(namespace){
    container('compilebox'){
        try{
        delres = sh script: """kubectl delete namespace ${namespace}""", returnStdout: true
        if (delres!= null) && delres = "namespace "${namespace}" deleted"{
         echo "${delres} sucessfully"
        }else
        {
          

        }
        
        }catch (e){
            echo "Failed to delete resources, Please check with DevOps"
        }
    }
}



def checkappStatus(){
    container('compilebox'){
        try{
            String query = "select _BRANCH_NAME from envmap_TABLE"
            assert queryOut instanceof String[]
            incrementalManager.createDbUtilsMulti()
            res = incrementalManager.executeMultiQuery(query, DB_URL, DB_CREDENTIALS_ID, vendor = 'mssql')
            //res = res.minus('\n')
            res = res.replaceAll("[\n\r]", "");
            res = res.replace("]",",").replace("[_BRANCH_NAME:","")
            //res = res.split(',')
            if (res.trim() == "null" ){
                echo "No records exist."
            }else{
                if (res.trim()!="null"){
                    res = res.split(',')
                    // def queryOutSize = queryOut.size()
                   //    println "the length of queryOut is: " + queryOutSize
                    //println queryOut[2]
                       qsize = (res.size());
                       println(qsize)
                    for (int i = 0;i<qsize;i++)
                        {
                          //println("pinging ${res[i]}")
                          //sh script: """ping -n 2 ${res[i]} """, returnStdout: true
                          println("${res}")
                          /*println(res[0])
                          println(res[1])
                          printlne(res[2])*/
                          
                          remoteBranchExist(repoUrl, res[i])
                        }
                }
            }

        }catch(e){
         throw e
        }
    }
}


def remoteBranchExist(repoUrl, branchName){
        container('compilebox'){
            withCredentials([usernamePassword(credentialsId: 'supermanaccount', passwordVariable: 'password', usernameVariable: 'username')]){
            sh script: "cd ~/ && echo machine az-nat.blablah.com > .netrc && echo \'  login jenkins\' >> .netrc && echo \'  password ${password}\' >> .netrc"
            }
            try{
                
            sh script: """ git ls-remote --heads ${repoUrl} refs/heads/${branchName} | grep refs/heads/${branchName} >/dev/null
if [ "\$?" == "1" ] ; then echo "Branch doesn't exist"; exit; else  echo "Branch exists"; fi
                """
                }catch(e){
                    echo "TATA"
                }
            }
        }


def getStats(){
    getDuration = currentBuild.duration / 1000
    getStartTime = currentBuild.timestamp
    String getStartTime = new java.text.SimpleDateFormat("MM/dd/yyyy HH:mm:ss").format(new java.util.Date (epoch*1000));

echo "Build was triggered at ${getStartTime}"
echo "Total duration for the build was ${getDuration} seconds."
}


def getStats(){
    getDuration = currentBuild.duration / 1000
echo "Total duration for the build was ${getDuration} seconds."
}

getStats()
