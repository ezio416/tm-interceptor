bool SortClassMethod(const ClassMethod@ const &in a, const ClassMethod@ const &in b) {
    return true
        && a !is null
        && b !is null
        && a.name.ToLower() < b.name.ToLower()
    ;
}

bool SortGameClass(const GameClass@ const &in a, const GameClass@ const &in b) {
    return true
        && a !is null
        && b !is null
        && a.name.ToLower() < b.name.ToLower()
    ;
}
