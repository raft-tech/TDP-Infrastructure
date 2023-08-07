

commands to be run after instance instantiation:
ssh to instance:
```
ssh ssh -i ~/.ssh/${ssh_key_file} ec2-user@${ip}
```

Tell docker host to allow an insecure registry:
```
sudo touch /etc/docker/daemon.json
sudo chmod 0777 /etc/docker/daemon.json
sudo echo '{ "insecure-registries":["ec2-44-203-55-151.compute-1.amazonaws.com:8082"] }' > /etc/docker/daemon.json
sudo chmod 0644 /etc/docker/daemon.json
sudo service docker restart
```

Pull and run nexus image:
```
docker pull sonatype/nexus3
docker volume create --name nexus-data
docker run -d -p 8081:8081 -p 8082:8082 -p 8443:8443 --name nexus -v nexus-data:/nexus-data sonatype/nexus3
```

wait for nexus to be running
```
docker logs -f nexus
```

exec to container and get docker admin.password:
```
docker exec -it nexus /bin/bash
cat /nexus-data/admin.password
```

still inside container, create SSL cert:
```
mkdir /nexus-data/etc/ssl
cd !$

keytool -genkeypair -keystore keystore.jks -storepass password -alias amazonaws.com \
 -keyalg RSA -keysize 2048 -validity 5000 -keypass password \
 -dname 'CN=*.amazonaws.com, OU=Sonatype, O=Sonatype, L=Unspecified, ST=Unspecified, C=US' \
 -ext 'SAN=DNS:ec2-44-203-55-151.compute-1.amazonaws.com'

keytool -exportcert -keystore keystore.jks -alias amazonaws.com -rfc > docker.cert
keytool -importkeystore -srckeystore keystore.jks -destkeystore docker.p12 -deststoretype PKCS12

 cd /nexus-data/etc
 sed -i~ '1iapplication-port-ssl=8443' nexus.properties
 sed -i '1issl.etc=${karaf.data}/etc/ssl' nexus.properties
 
 sed -i '/nexus-args/c\nexus-args=${jetty.etc}/jetty.xml,${jetty.etc}/jetty-http.xml,${jetty.etc}/jetty-https.xml,${jetty.etc}/jetty-requestlog.xml' nexus.properties
```

or you can use vim to modify from the docker host
```
vi /var/lib/docker/volumes/nexus-data/etc/nexus.properites
```

navigate to nexus in browser ${ip}:8081
sign in as 'admin' with the password from the admin.password file

Server Administration and Configuration >> Repositories >> + Create Repository