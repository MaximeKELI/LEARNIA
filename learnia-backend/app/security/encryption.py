"""
Module de chiffrement et de sécurité des données
"""
import secrets
import hashlib
import base64
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from typing import Optional
import os


class EncryptionService:
    """Service de chiffrement des données sensibles"""

    def __init__(self, master_key: Optional[str] = None):
        """
        Initialise le service de chiffrement
        
        Args:
            master_key: Clé maître pour le chiffrement (optionnel)
        """
        self.master_key = master_key or os.getenv("ENCRYPTION_MASTER_KEY")
        if not self.master_key:
            # Générer une clé maître si aucune n'est fournie
            self.master_key = Fernet.generate_key().decode()
        
        # Dériver une clé de chiffrement à partir de la clé maître
        self.fernet_key = self._derive_key(self.master_key)
        self.fernet = Fernet(self.fernet_key)

    def _derive_key(self, password: str, salt: Optional[bytes] = None) -> bytes:
        """
        Dérive une clé de chiffrement à partir d'un mot de passe
        
        Args:
            password: Mot de passe ou clé maître
            salt: Sel pour le dérivation (optionnel)
        
        Returns:
            Clé dérivée en bytes
        """
        if salt is None:
            salt = b'learnia_salt_2024'  # Sel fixe pour la cohérence
        
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        return base64.urlsafe_b64encode(kdf.derive(password.encode()))

    def encrypt_text(self, text: str) -> str:
        """
        Chiffre un texte
        
        Args:
            text: Texte à chiffrer
        
        Returns:
            Texte chiffré en base64
        """
        if not text:
            return ""
        
        encrypted_bytes = self.fernet.encrypt(text.encode())
        return base64.urlsafe_b64encode(encrypted_bytes).decode()

    def decrypt_text(self, encrypted_text: str) -> str:
        """
        Déchiffre un texte
        
        Args:
            encrypted_text: Texte chiffré en base64
        
        Returns:
            Texte déchiffré
        """
        if not encrypted_text:
            return ""
        
        try:
            encrypted_bytes = base64.urlsafe_b64decode(encrypted_text.encode())
            decrypted_bytes = self.fernet.decrypt(encrypted_bytes)
            return decrypted_bytes.decode()
        except Exception:
            # En cas d'erreur de déchiffrement, retourner une chaîne vide
            return ""

    def encrypt_sensitive_data(self, data: dict) -> dict:
        """
        Chiffre les données sensibles d'un dictionnaire
        
        Args:
            data: Dictionnaire contenant les données
        
        Returns:
            Dictionnaire avec les données sensibles chiffrées
        """
        sensitive_fields = [
            'phone', 'email', 'full_name', 'school',
            'question', 'answer', 'text', 'summary'
        ]
        
        encrypted_data = data.copy()
        
        for field in sensitive_fields:
            if field in encrypted_data and encrypted_data[field]:
                encrypted_data[field] = self.encrypt_text(str(encrypted_data[field]))
        
        return encrypted_data

    def decrypt_sensitive_data(self, data: dict) -> dict:
        """
        Déchiffre les données sensibles d'un dictionnaire
        
        Args:
            data: Dictionnaire contenant les données chiffrées
        
        Returns:
            Dictionnaire avec les données sensibles déchiffrées
        """
        sensitive_fields = [
            'phone', 'email', 'full_name', 'school',
            'question', 'answer', 'text', 'summary'
        ]
        
        decrypted_data = data.copy()
        
        for field in sensitive_fields:
            if field in decrypted_data and decrypted_data[field]:
                decrypted_data[field] = self.decrypt_text(str(decrypted_data[field]))
        
        return decrypted_data

    def hash_sensitive_id(self, user_id: int, salt: Optional[str] = None) -> str:
        """
        Hache un ID utilisateur pour l'utiliser dans les logs
        
        Args:
            user_id: ID de l'utilisateur
            salt: Sel pour le hachage (optionnel)
        
        Returns:
            ID haché
        """
        if salt is None:
            salt = "learnia_user_salt"
        
        hash_input = f"{user_id}_{salt}".encode()
        return hashlib.sha256(hash_input).hexdigest()[:16]

    def generate_secure_token(self, length: int = 32) -> str:
        """
        Génère un token sécurisé
        
        Args:
            length: Longueur du token
        
        Returns:
            Token sécurisé
        """
        return secrets.token_urlsafe(length)

    def generate_api_key(self) -> str:
        """
        Génère une clé API sécurisée
        
        Returns:
            Clé API
        """
        return f"lk_{secrets.token_urlsafe(32)}"

    def verify_token_integrity(self, token: str, expected_length: int = 32) -> bool:
        """
        Vérifie l'intégrité d'un token
        
        Args:
            token: Token à vérifier
            expected_length: Longueur attendue
        
        Returns:
            True si le token est valide
        """
        if not token or len(token) != expected_length:
            return False
        
        try:
            # Vérifier que le token peut être décodé en base64
            base64.urlsafe_b64decode(token + "==")  # Ajouter padding si nécessaire
            return True
        except Exception:
            return False


class DataMasking:
    """Classe pour masquer les données sensibles dans les logs"""

    @staticmethod
    def mask_email(email: str) -> str:
        """Masque une adresse email"""
        if not email or '@' not in email:
            return email
        
        local, domain = email.split('@', 1)
        if len(local) <= 2:
            return f"{local[0]}*@{domain}"
        
        return f"{local[0]}{'*' * (len(local) - 2)}{local[-1]}@{domain}"

    @staticmethod
    def mask_phone(phone: str) -> str:
        """Masque un numéro de téléphone"""
        if not phone or len(phone) < 4:
            return phone
        
        return f"{phone[:2]}{'*' * (len(phone) - 4)}{phone[-2:]}"

    @staticmethod
    def mask_name(name: str) -> str:
        """Masque un nom complet"""
        if not name or len(name) <= 2:
            return name
        
        parts = name.split()
        if len(parts) == 1:
            return f"{parts[0][0]}{'*' * (len(parts[0]) - 1)}"
        
        masked_parts = []
        for part in parts:
            if len(part) <= 1:
                masked_parts.append(part)
            else:
                masked_parts.append(f"{part[0]}{'*' * (len(part) - 1)}")
        
        return " ".join(masked_parts)

    @staticmethod
    def mask_text(text: str, visible_chars: int = 4) -> str:
        """Masque un texte générique"""
        if not text or len(text) <= visible_chars:
            return text
        
        return f"{text[:visible_chars]}{'*' * (len(text) - visible_chars)}"


# Instance globale du service de chiffrement
encryption_service = EncryptionService()
