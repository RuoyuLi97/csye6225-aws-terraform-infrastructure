package com.example;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import io.restassured.RestAssured;
import org.junit.jupiter.api.BeforeAll;
import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.notNullValue;

@SpringBootTest
public class MovieTest {
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
    public void testGetMovieByIdSuccess() {
        given().header("Authorization", "Bearer " + accessToken)
                .when()
                .get("/v1/movie/1")
                .then()
                .statusCode(200)
                .body("movieId", equalTo(1))
                .body("title", notNullValue())
                .body("genres", notNullValue());
    }

    @Test
    public void testGetMovieByIdQueryParam(){
        given().header("Authorization", "Bearer " + accessToken)
                .when()
                .get("/v1/movie?id=1")
                .then()
                .statusCode(200)
                .body("movieId", equalTo(1))
                .body("title", notNullValue())
                .body("genres", notNullValue());
    }

    @Test
    public void testGetMovieByIdFailure() {
        given().header("Authorization", "Bearer " + accessToken)
                .when()
                .get("/v1/movie/999999")
                .then()
                .statusCode(404);
    }

    @Test
    public void testUnauthorizedMovieAccess() {
        given().when()
                .get("/v1/movie/1")
                .then()
                .statusCode(401);
    }
}
