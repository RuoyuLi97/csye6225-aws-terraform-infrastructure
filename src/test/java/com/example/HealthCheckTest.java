package com.example;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.BeforeAll;
import static io.restassured.RestAssured.given;

@SpringBootTest
public class HealthCheckTest {
    @BeforeAll
    static void setup() {
        RestAssured.baseURI = System.getenv("BASE_URL");
    }

    @Test
    public void testHealthCheckSuccess() {
        given().contentType(ContentType.JSON)
                .when()
                .get("/v1/healthcheck")
                .then()
                .statusCode(200);
    }
}
