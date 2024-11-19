package com.example.spring_graphql.controller;

import com.example.spring_graphql.Author;
import com.example.spring_graphql.Book;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.graphql.data.method.annotation.SubscriptionMapping;
import org.springframework.stereotype.Controller;
import reactor.core.publisher.Flux;

import java.time.Duration;

@Controller
public class BookController {

    @QueryMapping
    public Book bookById(@Argument String id){
        return Book.getById(id);
    }

    @SchemaMapping
    public Author author(Book book){
        return Author.getById(book.authorId());
    }

    @SubscriptionMapping
    public Flux<Integer> countdown() {
        return Flux.range(1, 5)
                .map(i -> 6 - i)
                .delayElements(Duration.ofSeconds(1));
    }
}
