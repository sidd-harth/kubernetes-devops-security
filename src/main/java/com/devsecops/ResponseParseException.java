package com.devsecops;

public class ResponseParseException extends RuntimeException {
    public ResponseParseException(String message) {
        super(message);
    }

    public ResponseParseException(String message, Throwable cause) {
        super(message, cause);
    }
}
