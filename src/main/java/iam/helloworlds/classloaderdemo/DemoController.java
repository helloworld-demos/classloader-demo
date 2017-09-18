package iam.helloworlds.classloaderdemo;

import lombok.Data;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
public class DemoController {
    @RequestMapping("/demo")
    public List<Info> greeting() {
        return Arrays.stream(new String[]{
                "java.lang.String",
                "com.google.common.math.BigIntegerMath",
                "javax.ws.rs.core.Response",
                "com.fasterxml.jackson.databind.ObjectMapper"
        }).map(Info::new).collect(Collectors.toList());
    }
}

@Data
class Info {
    private String className;
    private boolean doesExist;
    private String classLoaderName;
    private String jarUrl;

    Info(String className) {
        this.className = className;

        try {
            Class<?> clazz = Class.forName(className);

            doesExist = true;
            Optional<ClassLoader> classLoader = Optional.ofNullable(clazz.getClassLoader());

            if (classLoader.isPresent()) {
                this.classLoaderName = classLoader.get().toString();
                this.jarUrl = classLoader.get().getResource(clazz.getName().replace('.', '/') + ".class").toString();
            }
        } catch (ClassNotFoundException e) {
            doesExist = false;
        }
    }
}
