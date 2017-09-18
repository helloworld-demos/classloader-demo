# ClassLoader

| port | description                              |
| ---- | ---------------------------------------- |
| 9001 | glassfish with using WebAppClassLoader <class-loader delegate="false"/> |
| 9002 | glassfish without using WebAppClassLoader <class-loader delegate="true"/> |
| 9003 | tomcat, default                          |



## Explanation

1. `java.lang.String` is loaded by `bootstrap` class loader which is `null` here since it is the 'parent' of application class loader

2. `javax.ws.rs-api` is included in glassfish since it is a J2EE application server, and it comes with lots of J2EE implementation. So `javax.ws.rs-api` should be **excluded** from application war file, otherwise the version may differ from the one in the maven/gradle file.

   ```
   compileOnly group: 'javax.ws.rs', name: 'javax.ws.rs-api', version: '2.1'
   ```

3. By using `WebAppClassLoader`, glassfish will try to load **third-party** classes from application library first which is included in war file.

   For example, `ObjectMapper` is loaded from war file.

   However, `ObjectMapper` is loaded from glassfish itself if `WebAppClassLoader` is not used

4. By default, tomcat loads **third-party** classes from application library first

5. Tomcat is just a servlet container, so it doesn't have `javax.ws.rs-api` included.



## Sample

run those commands:

```shell
(cd demo/ && ./demo.sh) && cat demo/result.log
```

result is:

```l
===============================================
curl -X GET localhost:9001/classloader-demo/demo
===============================================
[ {
  "className" : "java.lang.String",
  "doesExist" : true,
  "classLoaderName" : null,
  "jarUrl" : null
}, {
  "className" : "com.google.common.math.BigIntegerMath",
  "doesExist" : true,
  "classLoaderName" : "WebappClassLoader (delegate=false; repositories=WEB-INF/classes/)",
  "jarUrl" : "jar:file:/usr/glassfish4/glassfish/domains/domain1/applications/classloader-demo/WEB-INF/lib/guava-22.0.jar!/com/google/common/math/BigIntegerMath.class"
}, {
  "className" : "javax.ws.rs.core.Response",
  "doesExist" : true,
  "classLoaderName" : "javax.ws.rs-api [195]",
  "jarUrl" : "bundle://195.0:1/javax/ws/rs/core/Response.class"
}, {
  "className" : "com.fasterxml.jackson.databind.ObjectMapper",
  "doesExist" : true,
  "classLoaderName" : "WebappClassLoader (delegate=false; repositories=WEB-INF/classes/)",
  "jarUrl" : "jar:file:/usr/glassfish4/glassfish/domains/domain1/applications/classloader-demo/WEB-INF/lib/jackson-databind-2.8.8.jar!/com/fasterxml/jackson/databind/ObjectMapper.class"
} ]
===============================================
curl -X GET localhost:9002/classloader-demo/demo
===============================================
[ {
  "className" : "java.lang.String",
  "doesExist" : true,
  "classLoaderName" : null,
  "jarUrl" : null
}, {
  "className" : "com.google.common.math.BigIntegerMath",
  "doesExist" : true,
  "classLoaderName" : "com.google.guava [274]",
  "jarUrl" : "bundle://274.0:1/com/google/common/math/BigIntegerMath.class"
}, {
  "className" : "javax.ws.rs.core.Response",
  "doesExist" : true,
  "classLoaderName" : "javax.ws.rs-api [195]",
  "jarUrl" : "bundle://195.0:1/javax/ws/rs/core/Response.class"
}, {
  "className" : "com.fasterxml.jackson.databind.ObjectMapper",
  "doesExist" : true,
  "classLoaderName" : "com.fasterxml.jackson.core.jackson-databind [276]",
  "jarUrl" : "bundle://276.0:1/com/fasterxml/jackson/databind/ObjectMapper.class"
} ]
===============================================
curl -X GET localhost:9003/classloader-demo/demo
===============================================
[ {
  "className" : "java.lang.String",
  "doesExist" : true,
  "classLoaderName" : null,
  "jarUrl" : null
}, {
  "className" : "com.google.common.math.BigIntegerMath",
  "doesExist" : true,
  "classLoaderName" : "ParallelWebappClassLoader\r\n  context: classloader-demo\r\n  delegate: false\r\n----------> Parent Classloader:\r\njava.net.URLClassLoader@4eec7777\r\n",
  "jarUrl" : "jar:file:/usr/local/tomcat/webapps/classloader-demo/WEB-INF/lib/guava-22.0.jar!/com/google/common/math/BigIntegerMath.class"
}, {
  "className" : "javax.ws.rs.core.Response",
  "doesExist" : false,
  "classLoaderName" : null,
  "jarUrl" : null
}, {
  "className" : "com.fasterxml.jackson.databind.ObjectMapper",
  "doesExist" : true,
  "classLoaderName" : "ParallelWebappClassLoader\r\n  context: classloader-demo\r\n  delegate: false\r\n----------> Parent Classloader:\r\njava.net.URLClassLoader@4eec7777\r\n",
  "jarUrl" : "jar:file:/usr/local/tomcat/webapps/classloader-demo/WEB-INF/lib/jackson-databind-2.8.8.jar!/com/fasterxml/jackson/databind/ObjectMapper.class"
} ]
```

