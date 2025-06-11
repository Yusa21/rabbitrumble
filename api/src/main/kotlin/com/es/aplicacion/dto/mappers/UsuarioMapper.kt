package com.es.aplicacion.dto.mappers

import com.es.aplicacion.dto.usuario.SaveDataUsuarioDTO
import com.es.aplicacion.dto.usuario.UsuarioRegisterDTO
import com.es.aplicacion.dto.usuario.UsuarioResponseDTO
import com.es.aplicacion.model.Usuario
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Component

@Component
class UsuarioMapper {
    @Autowired
    private lateinit var passwordEncoder: PasswordEncoder

    // La contraseña se codifica aquí
    fun toEntity(dto: UsuarioRegisterDTO): Usuario {
        return Usuario(
            _id = null,
            username = dto.username!!,
            password = passwordEncoder.encode(dto.password),
            roles = "USER",
            unlockedCharacters = dto.unlocked_characters,
            unlockedStages = dto.unlocked_stages,
            completedStages = dto.completed_stages
        )
    }

    // Los roles no se pueden actualizar, se mantiene el anterior
    fun toUpdateEntity(existingUser: Usuario, dto: UsuarioRegisterDTO): Usuario {
        return Usuario(
            _id = existingUser._id,
            username = dto.username!!,
            password = passwordEncoder.encode(dto.password),
            roles = existingUser.roles,
            unlockedCharacters = dto.unlocked_characters,
            unlockedStages = dto.unlocked_stages,
            completedStages = dto.completed_stages
        )
    }

    fun toUpdateGameDataEntity(existingUser: Usuario, saveData: SaveDataUsuarioDTO): Usuario {
        return Usuario(
            _id = existingUser._id,
            username = existingUser.username,
            password = existingUser.password,
            roles = existingUser.roles,
            unlockedCharacters = saveData.unlocked_characters,
            unlockedStages = saveData.unlocked_stages,
            completedStages = saveData.completed_stages
        )
    }

    fun toResponseDTO(entity: Usuario): UsuarioResponseDTO {
        return UsuarioResponseDTO(
            username = entity.username,
            rol = entity.roles
        )
    }
}