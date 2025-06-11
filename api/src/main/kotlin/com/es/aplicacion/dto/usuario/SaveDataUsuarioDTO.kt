package com.es.aplicacion.dto.usuario

data class SaveDataUsuarioDTO(
    val unlocked_characters: Array<String>,
    val unlocked_stages: Array<String>,
    val completed_stages: Array<String>
)
