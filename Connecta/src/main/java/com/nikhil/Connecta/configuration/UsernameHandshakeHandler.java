package com.nikhil.Connecta.configuration;

import org.springframework.http.server.ServerHttpRequest;
import org.springframework.lang.NonNull;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.support.DefaultHandshakeHandler;
import org.springframework.web.util.UriComponentsBuilder;

import java.security.Principal;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/**
 * Assigns a user Principal during the WebSocket handshake so Spring's
 * user-destination routing (`/user/queue/...`) works without auth.
 *
 * Client must connect to `/ws?username=<name>`.
 */
public class UsernameHandshakeHandler extends DefaultHandshakeHandler {

    @Override
    protected Principal determineUser(
            @NonNull ServerHttpRequest request,
            @NonNull WebSocketHandler wsHandler,
            @NonNull Map<String, Object> attributes
    ) {
        String username = Optional.ofNullable(request.getURI())
                .map(uri -> UriComponentsBuilder.fromUri(uri).build().getQueryParams().getFirst("username"))
                .filter(s -> !s.isBlank())
                .orElse("anon-" + UUID.randomUUID());

        final String principalName = username.trim();
        return () -> principalName;
    }
}

