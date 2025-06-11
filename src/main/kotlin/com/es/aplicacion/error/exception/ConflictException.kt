package com.es.aplicacion.error.exception

class ConflictException(message: String): Exception("Conflict exception (407). $message") {
}