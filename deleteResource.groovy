/* This one can take namespace as an argument and can delete namespace object
*/

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
