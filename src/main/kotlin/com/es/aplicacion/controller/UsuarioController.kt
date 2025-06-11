package com.es.aplicacion.controller

import com.es.aplicacion.dto.usuario.LoginUsuarioDTO
import com.es.aplicacion.dto.usuario.SaveDataUsuarioDTO
import com.es.aplicacion.dto.usuario.UsuarioRegisterDTO
import com.es.aplicacion.dto.usuario.UsuarioResponseDTO
import com.es.aplicacion.error.exception.UnauthorizedException
import com.es.aplicacion.service.TokenService
import com.es.aplicacion.service.UsuarioService
import jakarta.servlet.http.HttpServletRequest
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.Authentication
import org.springframework.security.core.AuthenticationException
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/usuarios")
class UsuarioController {

    @Autowired
    private lateinit var authenticationManager: AuthenticationManager
    @Autowired
    private lateinit var tokenService: TokenService
    @Autowired
    private lateinit var usuarioService: UsuarioService

    @PostMapping("/register")
    fun insert(
        httpRequest: HttpServletRequest,
        @RequestBody usuarioRegisterDTO: UsuarioRegisterDTO
    ): ResponseEntity<UsuarioResponseDTO> {
        val usuarioInsertadoDTO: UsuarioResponseDTO = usuarioService.insertUser(usuarioRegisterDTO)
        return ResponseEntity(usuarioInsertadoDTO, HttpStatus.CREATED)
    }

    @PostMapping("/login")
    fun login(@RequestBody usuario: LoginUsuarioDTO): ResponseEntity<Any> {
        val authentication: Authentication
        try {
            authentication = authenticationManager.authenticate(
                UsernamePasswordAuthenticationToken(
                    usuario.username,
                    usuario.password
                )
            )
        } catch (e: AuthenticationException) {
            throw UnauthorizedException("Credenciales incorrectas")
        }

        // Generamos el token si pasamos la autenticación
        val token = tokenService.generarToken(authentication)
        return ResponseEntity(mapOf("token" to token), HttpStatus.CREATED)
    }

    @GetMapping("/")
    fun getAllUsers(): ResponseEntity<List<UsuarioResponseDTO>> {
        val usuarios = usuarioService.findAllUsers()
        return ResponseEntity.ok(usuarios.map {
            UsuarioResponseDTO(it.username, it.roles)
        })
    }

    @GetMapping("/{id}")
    fun getUserById(@PathVariable id: String): ResponseEntity<UsuarioResponseDTO> {
        val usuario = usuarioService.findUserById(id)
        return ResponseEntity.ok(UsuarioResponseDTO(usuario.username, usuario.roles))
    }

    @GetMapping("/self")
    fun getUserSelf(): ResponseEntity<UsuarioResponseDTO> {
        // Saca el usuario que está logueado usando el nombre, es el que envía
        val usuario = usuarioService.findUserByUsername(SecurityContextHolder.getContext().authentication.name)
        return ResponseEntity.ok(UsuarioResponseDTO(usuario.username, usuario.roles))
    }

    @PutMapping("/{id}")
    fun updateUser(
        @PathVariable id: String,
        @RequestBody updatedUser: UsuarioRegisterDTO
    ): ResponseEntity<UsuarioResponseDTO> {
        val usuario = usuarioService.updateUser(id, updatedUser)
        return ResponseEntity.ok(usuario)
    }

    @PutMapping("/self")
    fun updateUserSelf(
        @RequestBody updatedUser: UsuarioRegisterDTO
    ): ResponseEntity<UsuarioResponseDTO> {
        // Saca el usuario que está logueado usando el nombre, es el que envía
        val currentUser = usuarioService.findUserByUsername(SecurityContextHolder.getContext().authentication.name)
        val usuario = usuarioService.updateUser(currentUser._id!!, updatedUser)
        return ResponseEntity.ok(usuario)
    }

    @DeleteMapping("/{id}")
    fun deleteUser(@PathVariable id: String): ResponseEntity<Void> {
        usuarioService.deleteUser(id)
        return ResponseEntity.noContent().build()
    }

    @DeleteMapping("/self")
    fun deleteUserSelf(): ResponseEntity<Void> {
        // Saca el usuario que está logueado usando el nombre, es el que envía
        val currentUser = usuarioService.findUserByUsername(SecurityContextHolder.getContext().authentication.name)
        usuarioService.deleteUser(currentUser._id!!)
        return ResponseEntity.noContent().build()
    }

    // Nuevos endpoints para manejo de datos del juego
    @GetMapping("/self/gamedata")
    fun getUserGameData(): ResponseEntity<SaveDataUsuarioDTO> {
        val currentUsername = SecurityContextHolder.getContext().authentication.name
        val gameData = usuarioService.getUserGameData(currentUsername)
        return ResponseEntity.ok(gameData)
    }

    @PutMapping("/self/gamedata")
    fun updateUserGameData(
        @RequestBody saveData: SaveDataUsuarioDTO
    ): ResponseEntity<UsuarioResponseDTO> {
        val currentUsername = SecurityContextHolder.getContext().authentication.name
        val usuario = usuarioService.updateUserGameData(currentUsername, saveData)
        return ResponseEntity.ok(usuario)
    }

    @GetMapping("/{username}/gamedata")
    fun getUserGameDataByUsername(@PathVariable username: String): ResponseEntity<SaveDataUsuarioDTO> {
        val gameData = usuarioService.getUserGameData(username)
        return ResponseEntity.ok(gameData)
    }

    @PutMapping("/{username}/gamedata")
    fun updateUserGameDataByUsername(
        @PathVariable username: String,
        @RequestBody saveData: SaveDataUsuarioDTO
    ): ResponseEntity<UsuarioResponseDTO> {
        val usuario = usuarioService.updateUserGameData(username, saveData)
        return ResponseEntity.ok(usuario)
    }
}