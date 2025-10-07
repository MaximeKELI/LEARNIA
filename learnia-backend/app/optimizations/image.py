"""
Optimisations d'images pour améliorer les performances OCR
"""
import io
from PIL import Image, ImageOps, ImageEnhance
from typing import Tuple, Optional
from loguru import logger


class ImageOptimizer:
    """Classe pour optimiser les images avant traitement OCR"""

    def __init__(self):
        self.max_width = 1200
        self.max_height = 1200
        self.quality = 85

    def optimize_for_ocr(
        self, 
        image_data: bytes, 
        target_size: Optional[Tuple[int, int]] = None
    ) -> bytes:
        """
        Optimise une image pour l'OCR
        
        Args:
            image_data: Données de l'image en bytes
            target_size: Taille cible (largeur, hauteur)
        
        Returns:
            Données de l'image optimisée
        """
        try:
            # Ouvrir l'image
            image = Image.open(io.BytesIO(image_data))
            
            # Convertir en RGB si nécessaire
            if image.mode != 'RGB':
                image = image.convert('RGB')
            
            # Redimensionner si nécessaire
            if target_size:
                image = self._resize_image(image, target_size)
            else:
                image = self._resize_image(image, (self.max_width, self.max_height))
            
            # Améliorer le contraste
            image = self._enhance_contrast(image)
            
            # Convertir en niveaux de gris
            image = image.convert('L')
            
            # Sauvegarder avec compression
            output = io.BytesIO()
            image.save(
                output, 
                format='JPEG', 
                quality=self.quality,
                optimize=True
            )
            
            optimized_data = output.getvalue()
            
            # Log de l'optimisation
            original_size = len(image_data)
            optimized_size = len(optimized_data)
            compression_ratio = (1 - optimized_size / original_size) * 100
            
            logger.info(
                f"Image optimisée: {original_size} -> {optimized_size} bytes "
                f"({compression_ratio:.1f}% de réduction)"
            )
            
            return optimized_data
            
        except Exception as e:
            logger.error(f"Erreur lors de l'optimisation de l'image: {e}")
            return image_data

    def _resize_image(self, image: Image.Image, target_size: Tuple[int, int]) -> Image.Image:
        """
        Redimensionne une image en préservant les proportions
        
        Args:
            image: Image à redimensionner
            target_size: Taille cible (largeur, hauteur)
        
        Returns:
            Image redimensionnée
        """
        max_width, max_height = target_size
        width, height = image.size
        
        # Calculer les nouvelles dimensions
        if width <= max_width and height <= max_height:
            return image
        
        # Calculer le ratio de redimensionnement
        width_ratio = max_width / width
        height_ratio = max_height / height
        ratio = min(width_ratio, height_ratio)
        
        new_width = int(width * ratio)
        new_height = int(height * ratio)
        
        # Redimensionner avec interpolation de qualité
        return image.resize((new_width, new_height), Image.Resampling.LANCZOS)

    def _enhance_contrast(self, image: Image.Image) -> Image.Image:
        """
        Améliore le contraste de l'image
        
        Args:
            image: Image à améliorer
        
        Returns:
            Image avec contraste amélioré
        """
        # Améliorer le contraste
        enhancer = ImageEnhance.Contrast(image)
        image = enhancer.enhance(1.2)
        
        # Améliorer la netteté
        enhancer = ImageEnhance.Sharpness(image)
        image = enhancer.enhance(1.1)
        
        return image

    def preprocess_for_ocr(self, image_data: bytes) -> bytes:
        """
        Prétraite une image pour améliorer la reconnaissance OCR
        
        Args:
            image_data: Données de l'image
        
        Returns:
            Données de l'image prétraitée
        """
        try:
            # Ouvrir l'image
            image = Image.open(io.BytesIO(image_data))
            
            # Convertir en RGB si nécessaire
            if image.mode != 'RGB':
                image = image.convert('RGB')
            
            # Redimensionner pour l'OCR (résolution optimale)
            image = self._resize_image(image, (800, 600))
            
            # Améliorer le contraste
            image = self._enhance_contrast(image)
            
            # Convertir en niveaux de gris
            image = image.convert('L')
            
            # Appliquer un filtre de netteté
            image = ImageOps.autocontrast(image)
            
            # Sauvegarder
            output = io.BytesIO()
            image.save(output, format='PNG', optimize=True)
            
            return output.getvalue()
            
        except Exception as e:
            logger.error(f"Erreur lors du prétraitement OCR: {e}")
            return image_data

    def get_image_info(self, image_data: bytes) -> dict:
        """
        Obtient les informations d'une image
        
        Args:
            image_data: Données de l'image
        
        Returns:
            Informations de l'image
        """
        try:
            image = Image.open(io.BytesIO(image_data))
            
            return {
                "format": image.format,
                "mode": image.mode,
                "size": image.size,
                "width": image.width,
                "height": image.height,
                "file_size": len(image_data),
                "aspect_ratio": image.width / image.height if image.height > 0 else 0
            }
            
        except Exception as e:
            logger.error(f"Erreur lors de l'analyse de l'image: {e}")
            return {"error": str(e)}

    def batch_optimize(self, images_data: list) -> list:
        """
        Optimise plusieurs images en lot
        
        Args:
            images_data: Liste des données d'images
        
        Returns:
            Liste des images optimisées
        """
        optimized_images = []
        
        for i, image_data in enumerate(images_data):
            try:
                optimized = self.optimize_for_ocr(image_data)
                optimized_images.append(optimized)
                logger.debug(f"Image {i+1}/{len(images_data)} optimisée")
            except Exception as e:
                logger.error(f"Erreur lors de l'optimisation de l'image {i+1}: {e}")
                optimized_images.append(image_data)  # Garder l'original en cas d'erreur
        
        return optimized_images


# Instance globale de l'optimiseur d'images
image_optimizer = ImageOptimizer()


def optimize_image_for_ocr(image_data: bytes) -> bytes:
    """
    Fonction utilitaire pour optimiser une image pour l'OCR
    
    Args:
        image_data: Données de l'image
    
    Returns:
        Données de l'image optimisée
    """
    return image_optimizer.preprocess_for_ocr(image_data)


def get_optimal_image_size(image_data: bytes) -> Tuple[int, int]:
    """
    Calcule la taille optimale pour une image
    
    Args:
        image_data: Données de l'image
    
    Returns:
        Taille optimale (largeur, hauteur)
    """
    info = image_optimizer.get_image_info(image_data)
    
    if "error" in info:
        return (800, 600)  # Taille par défaut
    
    width, height = info["size"]
    
    # Calculer la taille optimale pour l'OCR
    max_width = 1200
    max_height = 1200
    
    if width <= max_width and height <= max_height:
        return (width, height)
    
    # Calculer le ratio de redimensionnement
    width_ratio = max_width / width
    height_ratio = max_height / height
    ratio = min(width_ratio, height_ratio)
    
    new_width = int(width * ratio)
    new_height = int(height * ratio)
    
    return (new_width, new_height)
