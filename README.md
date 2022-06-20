# horror894_platform
horror894 Platform repository

<details>
<summary> <b>HW №1 Kubernetes-intro</b> </summary>
=========================================

PODs: **kube-apiserver**, **kube-controller-manager**, **etcd-kube**, **kube-scheduler** are static pods that are not conrolled by k8s. Path to manifests for this pods set in kubelet conf. 
When we delete this pods using kubectl nothing happend.
When we delete containers, restoration triggered by probes set for this pods. 

PODs: **proxy** and **coredns** controlled by controller-manager. DaemonSet and ReplicaSet respectively.

What was done:
1. Created **kubernetes-intro/web/Dockerfile**. With python3 simple http. Image pushed to DockerHub - **horror894/intro-http:1.0**
2. Created **kubernetes-intro/web-pod.yaml**. Manifest include our image with http service and init container that create index.html page. To provide accesto the index.html file we use pod volume.  
3. Created docker image based on Dockerfile from [repo](https://github.com/GoogleCloudPlatform/microservices-demo/blob/master/src/frontend/Dockerfile) and pushed to DockerHub.
4. Using ad-hoc mode created **kubernetes-intro/frontend-pod.yaml**. 
5. After apply **kubernetes-intro/frontend-pod.yaml** pod has status Error.
6. Exec command "kubectl logs frontend" we saw that environment variabls not set.
6. Created new manifest **kubernetes-intro/frontend-pod-healthy.yaml** added variables from [repo](https://github.com/GoogleCloudPlatform/microservices-demo/blob/master/release/kubernetes-manifests.yaml). POD frontend in status "Running".
</details>

<details>
<summary> <b>HW №2 Kubernetes-controllers</b> </summary>
=========================================

* ***Why applying manifest **kubernetes-controllers/frontend-replicaset.yaml** with new ver. of app. didn't update running pods:***
Replicaset does not check that pods have a right template, replicaset controller filtered pods base on rs referens and selectors.
Than we compare count of received pods and count of replicas in configuration.

[Source](https://github.com/kubernetes/kubernetes/blob/master/pkg/controller/replicaset/replica_set.go): 
```Go
diff := len(filteredPods) - int(*(rs.Spec.Replicas))
if diff < 0 
```

* ***How DaemonSet could be applied to master nodes:***
K8s has mechanism [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
We have some system taints, in our case it's **node-role.kubernetes.io/master**. 
If we want run our DaemonSet on master node, we need to add toleration for that taint. 

What was done:
1. Created manifest **kubernetes-controllers/frontend-replicaset.yaml**, for deploy pods using replica set.
2. Template that we use for creating **kubernetes-controllers/frontend-replicaset.yaml** contain error, it missed section selector. Fixed.
3. Create two docker images and push them into docker **horror894/controllers-hipster-shop-paymentservice** tag v0.0.1 and v0.0.2
4. Create **kubernetes-controllers/paymentservice-replicaset.yaml**, replica count 3 app=v0.0.1. Apply it.
5. Create **kubernetes-controllers/paymentservice-deployment.yaml**, replica count 3 app=v.0.0.1 . Apply it.
6. Set app=v0.0.2 in **kubernetes-controllers/paymentservice-deployment.yaml** and apply it.
7. Made rollback using kubectl rollout undo.
8. Created **kubernetes-controllers/paymentservice-deployment-bg.yaml** for blue-green deployment and **kubernetes-controllers/paymentservice-deployment-reverse.yaml** for reverse rolling.
9. Created **kubernetes-controllers/frontend-deployment.yaml**, replica count 3 app=v0.0.1 and added description for readinessProbe.
10. Create **kubernetes-controllers/nodeexporter-daemonset.yaml** and check that we could receive metrics. 

</details>


<details>
<summary> <b>HW №3 Kubernetes-security</b> </summary>
=========================================

What was done:
1. Prepared manifests for creating required resources: user, namespace, clusterrole, role, bindings.
2. I checked rights of service accounts using "auth can-i" 

```Go
kubectl auth can-i <verb> <resource> --as=system:serviceaccount:<namespace>:<serviceaccountname> [-n <namespace>]
```

</details>



<details>
<summary> <b>HW №4 Kubernetes-networks</b> </summary>
=========================================

What was done:
1. Update kubernetes-intro/web-pod.yaml add some probes: readinessProbe and livenessProbe 
2. Create kubernetes-networks/web-deploy.yaml based on kubernetes-intro/web-pod.yaml
3. Create service with clusterIP - kubernetes-networks/web-svc-cip.yaml
4. Check that pod avalible throught clusterip inside cluster
5. Enable ipvs mode on kube-proxy
6. Install MetalLB
7. Configure MetalLB kubernetes-networks/metallb-config.yaml
8. Create service with LoadBalancer IP - kubernetes-networks/web-svc-lb.yaml
9. Check that addres was allocated
10. Add static route for network 172.17.255.0/24
11. Check that web pods availbel throught LoadBalancer IP
12. Create manifests for publishing dns ./coredns
13. Add annotation for sharing IP between services - metallb.universe.tf/allow-shared-ip: "Share-172-17-255-5"
14. Install nginx ingress controller
15. Create ingress service with LB IP - kubernetes-networks/nginx-lb.yaml
16. Create service type:ClusterIP with out allocation ClusterIP - kubernetes-networks/web-svc-headless.yaml
17. Create Ingress rule for service "web" - kubernetes-networks/web-ingress.yaml
18. Check that service "web" avalible thought Ingress
19. Install kubernetes-dashboard
20. Create manifest for publishing kubernetes-dashboard throught Ingress - kubernetes-networks/dashboard/kubernetes-dashboard-ingress.yaml
21. Create new deployments with different ver. of app
22. Create ingress rules to Redirecting part of the traffic to a dedicated group of pods should
redirect part of the traffic to the allocated group of pods. /canary
23. Check that request without header go app2 and request with header go to app2.


</details>



<details>
<summary> <b>HW №5 Kubernetes-volumes</b> </summary>
=========================================

What was done:
1. StatefulSet MinIO deployed
2. Headless Service Deployed
3. Secret configured with "type: Opaque ", deploy was changed to ref to created secret.


</details>

<details>
<summary> <b>HW №6 Kubernetes-tamplating</b> </summary>
=========================================

What was done:
1. Install nginx-ingress using helm. 
2. Install cert-manger using helm.
3. Created ClusterIssuer for prod and stage, it need for cert-manger knew who will issuing certs. - kubernetes-templating/cert-manager/
4. Created values - kubernetes-templating/chartmuseum/values.yaml. Install chartmuseum using helm. Checked that it work and ssl cert is ok.
5. Added parametr  --set env.open.DISABLE_API=false and re-install chartmuseum. :star:
6. Installed plugin "helm plugin install https://github.com/chartmuseum/helm-push". :star:
7. Created package "helm package clusterissue". :star:
8. Added new repo "helm repo add my-chartmuseum https://chartmuseum.68000.io". :star:
9. Pushed my chart "helm cm-push clusterissuer-0.1.0.tgz my-chartmuseum-https" :star:
10. Created values - kubernetes-templating/harbor/values.yaml. Install harbor using helm. Checked that it work and ssl cert is ok.
11. Created helmfile - kubernetes-templating/helmfile.yaml. Set value for install CRDs for cert-manager (Install nginx-ingress,cert-manager, harbor, chartmuseum). :star:
12. Created my own helm chart for hipster-shop app. 
13. Installed hipster-shop from my own helm chart, checked that it's work. 
14. Created separate helm chart for frontend service.
15. Re-installed hipster-shop with out frontend service. Checked that UI is not working. 
16. Installed frontend service using helm chart. Checked that UI is working.
17. Templated some variables for frontend service. - kubernetes-templating/frontend/values.yaml
18. Add frontend service as dependency for hipster-shop helm chat. 
19. Update dep for hipster-shop. 
20. Delete redis service from hipster-shop. Added public redis chart in hipster-shop dependency. :star:
21. Create secret.yaml and encrypt it.
22. Create template in frontend dir that will use encrypted secret.yaml. 
23. Install frontend chart and check that secret was added right. 
24. Add hipster-shop chart and frontend chart in my harbor. https://harbor.68000.io/
25. Created - kubernetes-templating/repo.sh
26. Delete services paymentservice and shippingservice from hipster-shop chart. 
27. Install kubecfg. 
28. Use more relevant kube.libsonnet - https://raw.githubusercontent.com/bitnami-labs/kube-libsonnet/master/kube.libsonnet
29. Create jsonnet template for services paymentservice and shippingservice. Add fiel name for container port because it's mandatory field for lib helper. - kubernetes-templating/kubecfg/services.jsonnet
30. Deploy services paymentservice and shippingservice using kubecfg.
31. Install qbec. :star:
32. Delete service productcatalog from hipster-shop. And configure deployment using qbec. Add files in - kubernetestemplating/jsonnet. :star:
33. Delete service cartservice from hipster-shop.
34. Prepare deployment for service cartservice using kustomize. Added files in - kubernetestemplating/kustomize. 


</details>
