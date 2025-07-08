package com.example;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import io.restassured.RestAssured;
import org.junit.jupiter.api.BeforeAll;
import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.instanceOf;

@SpringBootTest
public class RatingTest {
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
    public void testGetMovieRatings(){
        System.out.println(accessToken);
        given().header("Authorization", "Bearer " + accessToken)
                .when()
                .get("/v1/rating/1")
                .then()
                .statusCode(200)
                .body("movieId", equalTo(1))
                .body("average_rating", instanceOf(Float.class));
    }

    @Test
    public void testGetMovieRatingsNotFound(){
        given().header("Authorization", "Bearer " + accessToken)
                .when()
                .get("/v1/rating/999999")
                .then()
                .statusCode(404);
    }
}
