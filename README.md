# Dubbo Admin Image

## 使用方式

**dubbo.properties**

```properties
# zookeeper单机配置
dubbo.registry.address=zookeeper://127.0.0.1:2181
# zookeeper集群配置(参考网上的, 能不能用没有试过)
dubbo.registry.address=zookeeper://127.0.0.1:2181?backup=127.0.0.1:2182,127.0.0.1:2183
dubbo.admin.root.password=root
dubbo.admin.guest.password=guest
```

**使用配置文件**

```bash
$ docker run -d \
  --name dubbo-admin \
  -v $(pwd)/dubbo.properties:/usr/local/tomcat/webapps/ROOT/WEB-INF/dubbo.properties \
  -p 8080:8080 \
  liulik/dubbo-admin:2.8.4
```

**访问**

启动后访问对应地址，输入用户名密码，密码配置在：`dubbo.properties` 内

```
http://127.0.0.1:8080
```



**注**：此镜像仅通过 [Github · dangdangdotcom/dubbox](https://github.com/dangdangdotcom/dubbox) 项目源代码构建，不修改任何代码

## 构建

**构建**

> 前置需要jdk环境(这里使用jdk1.8)
>
> 前置需要maven环境(这里使用maven3.6.3)

下载或拉取 [Github · dangdangdotcom/dubbox](https://github.com/dangdangdotcom/dubbox) 对应分支代码到本地，切换到项目根目录，执行构建

```bash
# 需要跳过测试，要不然编译不成功
$ mvn clean install -Dmaven.test.skip=true
```

>进入`dubbo-admin\target`会看到生成的`dubbo-admin-x.x.x.war`包

**构建后使用**

>将生成的war包，解压到Tomcat的 `webapps` 目录下 `dubbo-admin` 目录(也可以解压到ROOT，ROOT访问的时候不需要加对应目录名称, 如 `dubbo-admin` )

修改配置：修改dubbo配置文件 `dubbo-admin/WEB-INF/dubbo.properties`

参考: [配置dubbo.properties](#使用方式)

