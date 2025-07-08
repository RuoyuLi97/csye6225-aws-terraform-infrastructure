package com.example;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import org.junit.jupiter.api.BeforeAll;
import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.notNullValue;

@SpringBootTest
public class LoginTest {
    private static String testEmail = "testuser@example.com";
    private static String testPassword = "1234567890";
    public static String accessToken;

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = System.getenv("BASE_URL");
    }

    @Test
    public void testLoginSuccess() {
        Response response = given().contentType(ContentType.JSON)
                .body("{\"email\":\"" + testEmail + "\", \"password\":\"" + testPassword + "\"}")
                .when()
                .post("/v1/login");
        
        accessToken = response.jsonPath().getString("token");
        
        response.then()
                .statusCode(200)
                .body("token", notNullValue());
    }

    public static String getAccessToken() {
        return accessToken;
    }

    @Test
    public void testLoginFailure() {
        given().contentType(ContentType.JSON)
                .body("{\"email\":\"wronguser@example.com\", \"password\":\"wrongpassword\"}")
                .when()
                .post("/v1/login")
                .then()
                .statusCode(400);
    }
}
