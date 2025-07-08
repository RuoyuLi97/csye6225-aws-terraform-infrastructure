package com.example;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.BeforeAll;
import static io.restassured.RestAssured.given;

@SpringBootTest
public class RegisterTest {
    private static String testEmail = "testuser@example.com";
    private static String testPassword = "1234567890";

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = System.getenv("BASE_URL");
    }

    @Test
    public void testRegisterSuccess() {
        given().contentType(ContentType.JSON)
                .body("{\"email\":\"" + testEmail + "\", \"password\":\"" + testPassword + "\"}")
                .when()
                .post("/v1/register")
                .then()
                .statusCode(201);
    }
}
