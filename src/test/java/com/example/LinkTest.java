package com.example;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import io.restassured.RestAssured;
import org.junit.jupiter.api.BeforeAll;
import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.notNullValue;

@SpringBootTest
public class LinkTest {
    private static String accessToken;

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = System.getenv("BASE_URL");
        if (accessToken == null) {
            LoginTest loginTest = new LoginTest();
            loginTest.testLoginSuccess();
            accessToken = LoginTest.getAccessToken();
        }
    }

    @Test
    public void testGetMovieLink(){
        given().header("Authorization", "Bearer " + accessToken)
                .when()
                .get("/v1/link/1")
                .then()
                .statusCode(200)
                .body("movieId", equalTo(1))
                .body("imdbId", notNullValue())
                .body("tmdbId", notNullValue());
    }
    
    @Test
    public void testGetMovieLinkNotFound(){
        given().header("Authorization", "Bearer " + accessToken)
                .when()
                .get("/v1/link/999999")
                .then()
                .statusCode(404);
    }
    
}