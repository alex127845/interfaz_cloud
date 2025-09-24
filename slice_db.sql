-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`security`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`security` (
  `idsecurity` INT NOT NULL,
  `tipo` VARCHAR(45) NULL,
  `descripcion` VARCHAR(45) NULL,
  PRIMARY KEY (`idsecurity`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`slice`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`slice` (
  `idslice` INT NOT NULL,
  `estado` VARCHAR(45) NULL,
  `topologia` VARCHAR(45) NULL,
  `fecha_creacion` DATE NULL,
  `fecha_upload` DATE NULL,
  `security_idsecurity` INT NOT NULL,
  PRIMARY KEY (`idslice`, `security_idsecurity`),
  INDEX `fk_slice_security1_idx` (`security_idsecurity` ASC) VISIBLE,
  CONSTRAINT `fk_slice_security1`
    FOREIGN KEY (`security_idsecurity`)
    REFERENCES `mydb`.`security` (`idsecurity`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`rol`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`rol` (
  `idrol` INT NOT NULL,
  `nombre_rol` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idrol`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`usuario` (
  `idusuario` INT NOT NULL,
  `nombre` VARCHAR(45) NULL,
  `contrasenia` VARCHAR(45) NULL,
  `rol_idrol` INT NOT NULL,
  PRIMARY KEY (`idusuario`, `rol_idrol`),
  INDEX `fk_usuario_rol1_idx` (`rol_idrol` ASC) VISIBLE,
  CONSTRAINT `fk_usuario_rol1`
    FOREIGN KEY (`rol_idrol`)
    REFERENCES `mydb`.`rol` (`idrol`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`instancia`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`instancia` (
  `idinstancia` INT NOT NULL,
  `slice_idslice` INT NOT NULL,
  `estado` VARCHAR(45) NULL,
  `cpu` VARCHAR(45) NULL,
  `ram` VARCHAR(45) NULL,
  `storage` VARCHAR(45) NULL,
  PRIMARY KEY (`idinstancia`, `slice_idslice`),
  INDEX `fk_instancia_slice1_idx` (`slice_idslice` ASC) VISIBLE,
  CONSTRAINT `fk_instancia_slice1`
    FOREIGN KEY (`slice_idslice`)
    REFERENCES `mydb`.`slice` (`idslice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`usuario_has_slice`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`usuario_has_slice` (
  `usuario_idusuario` INT NOT NULL,
  `slice_idslice` INT NOT NULL,
  PRIMARY KEY (`usuario_idusuario`, `slice_idslice`),
  INDEX `fk_usuario_has_slice_slice1_idx` (`slice_idslice` ASC) VISIBLE,
  INDEX `fk_usuario_has_slice_usuario_idx` (`usuario_idusuario` ASC) VISIBLE,
  CONSTRAINT `fk_usuario_has_slice_usuario`
    FOREIGN KEY (`usuario_idusuario`)
    REFERENCES `mydb`.`usuario` (`idusuario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_usuario_has_slice_slice1`
    FOREIGN KEY (`slice_idslice`)
    REFERENCES `mydb`.`slice` (`idslice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`interfaz`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`interfaz` (
  `idinterfaz` INT NOT NULL,
  `nombre_interfaz` VARCHAR(45) NULL,
  `instancia_idinstancia` INT NOT NULL,
  `instancia_slice_idslice` INT NOT NULL,
  PRIMARY KEY (`idinterfaz`, `instancia_idinstancia`, `instancia_slice_idslice`),
  INDEX `fk_interfaz_instancia1_idx` (`instancia_idinstancia` ASC, `instancia_slice_idslice` ASC) VISIBLE,
  CONSTRAINT `fk_interfaz_instancia1`
    FOREIGN KEY (`instancia_idinstancia` , `instancia_slice_idslice`)
    REFERENCES `mydb`.`instancia` (`idinstancia` , `slice_idslice`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
