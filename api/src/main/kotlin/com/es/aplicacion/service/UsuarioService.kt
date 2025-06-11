package com.es.aplicacion.service

import com.es.aplicacion.dto.mappers.UsuarioMapper
import com.es.aplicacion.dto.usuario.SaveDataUsuarioDTO
import com.es.aplicacion.dto.usuario.UsuarioRegisterDTO
import com.es.aplicacion.dto.usuario.UsuarioResponseDTO
import com.es.aplicacion.error.exception.BadRequestException
import com.es.aplicacion.error.exception.ConflictException
import com.es.aplicacion.error.exception.NotFoundException
import com.es.aplicacion.error.exception.UnauthorizedException
import com.es.aplicacion.model.Usuario
import com.es.aplicacion.repository.UsuarioRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.stereotype.Service

@Service
class UsuarioService : UserDetailsService {
    @Autowired
    private lateinit var usuarioRepository: UsuarioRepository
    @Autowired
    private lateinit var usuarioMapper: UsuarioMapper

    override fun loadUserByUsername(username: String?): UserDetails {
        val usuario: Usuario = usuarioRepository
            .findByUsername(username!!)
            .orElseThrow {
                UnauthorizedException("$username no existente")
            }

        return User.builder()
            .username(usuario.username)
            .password(usuario.password)
            .roles(usuario.roles)
            .build()
    }

    fun insertUser(usuarioRegisterDTO: UsuarioRegisterDTO): UsuarioResponseDTO {
        // Valida los datos a introducir
        validateUserData(usuarioRegisterDTO)
        validateGameData(usuarioRegisterDTO)

        // Valida que las contraseñas sean las mismas
        if(usuarioRegisterDTO.password != usuarioRegisterDTO.passwordRepeat) {
            throw BadRequestException("Las contraseñas no coinciden")
        }

        // Comprueba que el nombre esté disponible
        if(usuarioRepository.findByUsername(usuarioRegisterDTO.username!!).isPresent) {
            throw ConflictException("Usuario ${usuarioRegisterDTO.username} ya está registrado")
        }

        val usuario = usuarioMapper.toEntity(usuarioRegisterDTO)
        val savedUser = usuarioRepository.save(usuario)

        return usuarioMapper.toResponseDTO(savedUser)
    }

    fun updateUser(id: String, usuarioRegisterDTO: UsuarioRegisterDTO): UsuarioResponseDTO {
        // Valida los datos a introducir
        validateUserData(usuarioRegisterDTO)
        validateGameData(usuarioRegisterDTO)

        // Valida que las contraseñas sean las mismas
        if(usuarioRegisterDTO.password != usuarioRegisterDTO.passwordRepeat) {
            throw BadRequestException("Las contraseñas no coinciden")
        }

        val existingUser = usuarioRepository.findById(id)
            .orElseThrow { NotFoundException("Usuario con id $id no encontrado") }

        // Comprueba que el nombre esté disponible (si es diferente al actual)
        if(usuarioRegisterDTO.username != existingUser.username &&
            usuarioRepository.findByUsername(usuarioRegisterDTO.username!!).isPresent) {
            throw ConflictException("Usuario ${usuarioRegisterDTO.username} existente")
        }

        val updatedUser = usuarioMapper.toUpdateEntity(existingUser, usuarioRegisterDTO)
        val savedUser = usuarioRepository.save(updatedUser)

        return usuarioMapper.toResponseDTO(savedUser)
    }

    fun updateUserGameData(username: String, saveDataDTO: SaveDataUsuarioDTO): UsuarioResponseDTO {
        val existingUser = usuarioRepository.findByUsername(username)
            .orElseThrow { NotFoundException("Usuario $username no encontrado") }

        // Valida los datos del juego
        validateGameData(saveDataDTO)

        val updatedUser = usuarioMapper.toUpdateGameDataEntity(existingUser, saveDataDTO)
        val savedUser = usuarioRepository.save(updatedUser)

        return usuarioMapper.toResponseDTO(savedUser)
    }

    fun getUserGameData(username: String): SaveDataUsuarioDTO {
        val usuario = usuarioRepository.findByUsername(username)
            .orElseThrow { NotFoundException("Usuario $username no encontrado") }

        return SaveDataUsuarioDTO(
            unlocked_characters = usuario.unlockedCharacters,
            unlocked_stages = usuario.unlockedStages,
            completed_stages = usuario.completedStages
        )
    }

    fun findUserById(id: String): Usuario {
        return usuarioRepository.findById(id)
            .orElseThrow { NotFoundException("Usuario con id $id no encontrado") }
    }

    fun findUserByUsername(username: String): Usuario {
        return usuarioRepository.findByUsername(username)
            .orElseThrow { NotFoundException("Usuario $username no se ha encontrado") }
    }

    fun findAllUsers(): List<Usuario> {
        return usuarioRepository.findAll()
    }

    fun deleteUser(id: String) {
        if (!usuarioRepository.existsById(id)) {
            throw NotFoundException("Usuario con id $id no encontrado")
        }
        usuarioRepository.deleteById(id)
    }

    private fun validateUserData(usuario: UsuarioRegisterDTO) {
        val errors = mutableListOf<String>()

        // Comprueba que no haya nada nulo
        if (usuario.username.isNullOrBlank()) {
            errors.add("El nombre de usuario es obligatorio")
        }
        if (usuario.password.isNullOrBlank()) {
            errors.add("La contraseña es obligatoria")
        }

        if (errors.isNotEmpty()) {
            throw BadRequestException(errors.joinToString("."))
        }

        // Valida la longitud de los datos
        if (usuario.username!!.length > 50) {
            errors.add("La longitud máxima del nombre es 50 caracteres")
        }
        if (usuario.password!!.length > 50) {
            errors.add("La longitud máxima de la contraseña es 50 caracteres")
        }

        // Valida la seguridad de la contraseña
        if (!usuario.password.matches(Regex("^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"))) {
            errors.add("La contraseña debe tener al menos 8 caracteres, una letra y un número")
        }

        if (errors.isNotEmpty()) {
            throw BadRequestException(errors.joinToString("."))
        }
    }

    private fun validateGameData(saveData: SaveDataUsuarioDTO) {
        val errors = mutableListOf<String>()

        // Valida que los arrays no sean nulos
        if (saveData.unlocked_characters.isEmpty()) {
            errors.add("Los personajes desbloqueados no pueden estar vacíos")
        }
        if (saveData.unlocked_stages.isEmpty()) {
            errors.add("Las etapas desbloqueadas no pueden estar vacías")
        }

        // Valida que los elementos de los arrays no estén vacíos
        if (saveData.unlocked_characters.any { it.isBlank() }) {
            errors.add("Los nombres de personajes no pueden estar vacíos")
        }
        if (saveData.unlocked_stages.any { it.isBlank() }) {
            errors.add("Los nombres de etapas no pueden estar vacíos")
        }

        if (errors.isNotEmpty()) {
            throw BadRequestException(errors.joinToString("."))
        }
    }

    private fun validateGameData(registerData: UsuarioRegisterDTO) {
        val errors = mutableListOf<String>()

        // Valida que los arrays no sean nulos
        if (registerData.unlocked_characters.isEmpty()) {
            errors.add("Los personajes desbloqueados no pueden estar vacíos")
        }
        if (registerData.unlocked_stages.isEmpty()) {
            errors.add("Las etapas desbloqueadas no pueden estar vacías")
        }

        // Valida que los elementos de los arrays no estén vacíos
        if (registerData.unlocked_characters.any { it.isBlank() }) {
            errors.add("Los nombres de personajes no pueden estar vacíos")
        }
        if (registerData.unlocked_stages.any { it.isBlank() }) {
            errors.add("Los nombres de etapas no pueden estar vacíos")
        }

        if (errors.isNotEmpty()) {
            throw BadRequestException(errors.joinToString("."))
        }
    }
}