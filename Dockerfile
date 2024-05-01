# Use OpenJDK 11 as base image
FROM openjdk:11

# Set the working directory in the container
WORKDIR /app

# Copy the compiled Java file into the container
COPY ./target/my-java-project.jar /app/my-java-project.jar

# Command to run the Java application
CMD ["java", "-jar", "my-java-project.jar"]
