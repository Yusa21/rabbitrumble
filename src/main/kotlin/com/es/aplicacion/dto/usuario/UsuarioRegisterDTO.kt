package com.es.aplicacion.dto.usuario

data class UsuarioRegisterDTO(
    val username: String?,
    val password: String?,
    val passwordRepeat: String?,
    val unlocked_characters: Array<String>,
    val unlocked_stages: Array<String>,
    val completed_stages: Array<String>
)
