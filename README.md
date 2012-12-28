Kiln
====

# Overview

As described by [Wikipedia](http://en.wikipedia.org/wiki/Kiln), KILN is...

 > A kiln is a thermally insulated chamber, or oven, in which a controlled temperature regime is produced. Uses include the hardening, burning or drying of materials. Kilns are also used for the firing of materials, such as clay and other raw materials, to form ceramics (including pottery, bricks etc.)

Kiln is an open source platform for log aggregation, visualization and analysis. The goal of Kiln is to provide a one stop log visualization platform that provides engineers, managers, and other stakeholders access to log files for multiple applications and environments without the hassle of having to tail log files or browse complex directory structures on remote repositories such as the ones generated by applications deployed on Elastic Beanstalk.

Installing and deploying Kiln is easy, and publishing to Kiln is even easier. Kiln stores all of its data on database (**MongoDB**) enabling you to establish backup and storage policies that best fit your needs.

The source code for Kiln may be checked out from [GitHub](https://github.com/rcracel/Kiln).

# Server Configuration

Kiln comes pre-configured to connect to a MongoDB instance running on localhost with no authentication. Although this may be considered sufficient for testing purposes, when deploying to a production server you will probably want to configure to use a more robust database solution such as the many cloud solutions currently being offered as a service. To override the default configuration settings you must place a file named "kiln_mongo.yml" on the home directory of the user running your application server.

## ~/kiln_mongo.yml sample

```yaml
production:
  host: hosted.mongodb.com
  port: 10057
  database: kiln_production
  username: mongo_user
  password: s3cr3t
```

In addition to overriding the database configuration, there are a few other settings that can be overriden by adding a "kiln.yml" file to the home directory of the user running your application server.

## ~/kiln.yml sample

```yaml
defaults: &defaults
    allow_new_users: true

development:
    <<: *defaults

test:
    <<: *defaults

production:
    <<: *defaults
```

####\[environment\]:allow_new_users
Determines where the application allows new users to register. If set to false only existing users will have access to the application. You can use this option to prevent unauthorized users to see your log files.

## config/mongo.yml

####\[environment\]:host
The hostname or IP address of your MongoDB instance.
####\[environment\]:port
The port used to connect to your MongoDB instance.
####\[environment\]:database
The name of the database you want to use for storing the log events.
####\[environment\]:username
The username used to connect to your MongoDB instance. We recommend you leave this as an environment variable for easier configuration.
####\[environment\]:password
The password used to connect to your MongoDB instance. We recommend you leave this as an environment variable for easier configuration.

# Log4J Appender

If you are using Maven with Java or another JVM based languange, you can add a dependency to the Kiln adapter to your application, and usually through a simple configuration line push log events to your Kiln instance.

The project information and source code for the Log4J adaptor is currently available the [Project Page](https://github.com/rcracel/kiln-java-adaptor) on GitHub. Feel free to check it out, contribute or report bugs.

## Maven

### pom.xml

```
<dependency>
    <groupId>com.nevermindsoft</groupId>
    <artifactId>kiln-adaptor-java</artifactId>
    <version>1.5</version>
</dependency>
```

## Grails

### BuildConfig.groovy

```java
dependencies {
    runtime 'com.nevermindsoft:kiln-adaptor-java:1.5'
    ....
}
```

### Config.groovy
```java
log4j = {
    appenders {
        ....
        appender    new com.nevermindsoft.kiln.RemoteServiceAppender(
                name:            "remote",
                moduleName:      "My Module Name",
                apiKey:          "get-key-from-kiln",
                environmentName: grails.util.Environment.current.getName(),
                serverUrl:       "http://my.url/api/events/publish",
                maxRequestItems: 200,
                sleepTime:       5000
        )
    }
 
    ...
 
    root {
        info  'remote'
        ...
    }
}
```
# Restful API

Kiln's provides a restful JSON based api that can be used to gain access to repository functionality. You can use the API methods specified below to write new appender for additional programming languages, generate external reports, or even add monitors to notify stakeholders of potential risks from application errors or intrusion attempts.

## /api/events/publish

This method allows you to publish event logs to the repository. You will need to create an application and use the provided API Key to connect to Kiln.

### module_name
The name of the application module publishing this log event. This is usually a qualified stand alone part of your application or application suite. (optional)
### source
The location, in code, where the message originated from. This would tipically include the class name, method name, and, if available, a line number. (optional)
### log_level
The log level for this event. Examples are INFO, WARN, ERROR. (optional)
### message
The textual message for the log event.
### timestamp
The timestamp for the log event. The format is %m/%d/%Y %H:%M:%S %z. (optional)
### thread_name
The name of the application thread where the log event originated. This is helpful for detecting which worker thread on a multi-threaded application has generated the log. (optional)
### stack_trace
A string representation of the stack trace associated with the log event. This is useful for capturing exception stack traces for errors. (optional)
### environment_name
The name of the environment where the log event originated. This is useful to differentiate between development, staging, production or any other environments you may be maintaining concurrently on your project. (optional)

## Example request payload

```javascript
{
    api_key: "xxx-xxx-xxx",
    events: [
        {
            "module_name" : "Bulk Email Processor",
            "source" : "com.nevermindsoft.ApplicationInitializer.startUp() (133)",
            "log_level" : "INFO",
            "message" : "Application Successfully Initialized",
            "timestamp" : "12/21/2012 04:33:12 -5:00",
            "thread_name" : "MainThread",
            "environment_name" : "staging"
        },
        {
            "module_name" : "Bulk Email Processor",
            "source" : "com.nevermindsoft.EmailProcessor.checkState() (76)",
            "log_level" : "WARN",
            "message" : "Found unprocessed outbound messages, please ensure proper shutdown to prevent message loss.",
            "timestamp" : "12/21/2012 04:51:12 -5:00",
            "thread_name" : "WorkerThread-01",
            "environment_name" : "staging"
        }
    ]
}
```