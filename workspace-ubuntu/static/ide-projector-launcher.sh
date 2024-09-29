#!/bin/bash
# search for IDE runner sh file:

THIS_FILE_NAME=$(basename "$0")

ideRunnerCandidates=($(grep -lr --include=*.sh "com.intellij.idea.Main\|jetbrains.mps.Launcher" .))

# remove this file from candidates:
for i in "${!ideRunnerCandidates[@]}"; do
    if [[ ${ideRunnerCandidates[i]} = *$THIS_FILE_NAME* ]]; then
        unset 'ideRunnerCandidates[i]'
    elif [[ ${ideRunnerCandidates[i]} = *"projector"* ]]; then
        unset 'ideRunnerCandidates[i]'
    elif [[ ${ideRunnerCandidates[i]} = *"game-tools.sh" ]]; then
        unset 'ideRunnerCandidates[i]'
    fi
done

if [[ ${#ideRunnerCandidates[@]} != 1 ]]; then
    echo "Can't find a single candidate to be IDE runner script so can't select a single one:"
    echo ${ideRunnerCandidates[*]}
    exit 1
fi

ideRunnerCandidate=${ideRunnerCandidates[@]}
ideRunnerWithoutPrefix=${ideRunnerCandidate/"./"/""}
IDE_RUN_FILE_NAME=${ideRunnerWithoutPrefix/".sh"/""}
echo "Found IDE: $IDE_RUN_FILE_NAME"

cp "$IDE_RUN_FILE_NAME.sh" "$IDE_RUN_FILE_NAME-projector.sh"

# change
# classpath "$CLASSPATH"
# to
# classpath "$CLASSPATH:$IDE_HOME/projector-server/lib/*"
# for ideaIC-2021.2.3.tar.gz
# sed -i 's+classpath "$CLASSPATH"+classpath "$CLASSPATH:$IDE_HOME/projector-server/lib/*"+g' "$IDE_RUN_FILE_NAME-projector.sh"
# for ideaIC-2023.1.tar.gz
sed -i 's+classpath "$CLASS_PATH"+classpath "$CLASS_PATH:$IDE_HOME/projector-server/lib/*"+g' "$IDE_RUN_FILE_NAME-projector.sh"

# change
# com.intellij.idea.Main
# to
# -Dorg.jetbrains.projector.server.classToLaunch=com.intellij.idea.Main org.jetbrains.projector.server.ProjectorLauncher
sed -i 's+com.intellij.idea.Main+-Dorg.jetbrains.projector.server.classToLaunch=com.intellij.idea.Main org.jetbrains.projector.server.ProjectorLauncher+g' "$IDE_RUN_FILE_NAME-projector.sh"

# change
# ${MAIN_CLASS}
# to
# -Dorg.jetbrains.projector.server.classToLaunch=${MAIN_CLASS} org.jetbrains.projector.server.ProjectorLauncher
sed -i 's+\${MAIN_CLASS}+-Dorg.jetbrains.projector.server.classToLaunch=\${MAIN_CLASS} org.jetbrains.projector.server.ProjectorLauncher+g' "$IDE_RUN_FILE_NAME-projector.sh"

bash "$IDE_RUN_FILE_NAME-projector.sh"

rm "$IDE_RUN_FILE_NAME-projector.sh"
