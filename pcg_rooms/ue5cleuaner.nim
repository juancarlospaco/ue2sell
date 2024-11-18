import std/[os, strutils, json, sequtils]


proc main(cwd: string) =
  if dirExists(cwd / "Content"):
    # Minify uproject to valid minimal.
    for f in walkPattern(cwd / "*.uproject"):
      let uproject = parseFile(f)
      if uproject.contains"Category": uproject.delete"Category"
      if uproject.contains"Description": uproject.delete"Description"
      if uproject.contains"EngineAssociation": uproject.delete"EngineAssociation"
      writeFile(f, $uproject)
      echo "Minified\t", f
      break
    # Delete all caches.
    for folder in walkDirRec(cwd, yieldFilter = {pcDir}, relative=off, checkDir=off, skipSpecial=off):
      for f in ["DerivedDataCache", "Intermediate", "Binaries", "Build", "Saved", "Content" / "Collections", "Content" / "Developers"]:
        if folder == cwd / f:
          echo "Deleted\t", folder
          removeDir(folder)
    if dirExists(cwd / "Config"):
      for f in walkPattern(cwd / "Config" / "*.ini"):
        # Delete editor-specific local-only settings.
        if extractFilename(f) in ["DefaultEditorPerProjectUserSettings.ini", "DefaultGamePerProjectUserSettings.ini"]:
          if tryRemoveFile(f): echo "Deleted\t", f
        else:
          # Minify INI to valid minimal.
          writeFile(f, readFile(f).strip.splitLines.filterIt(it.strip.len > 0).join("\n"))
          echo "Minified\t", f
  else: quit "IO Error: Unreal Engine project folder not found or not writable."


when isMainModule:
  doAssert paramCount() == 1, "Full path to Unreal Engine project folder must be the only argument"
  main(paramStr(1))
