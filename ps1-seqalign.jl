base_idx = Dict{String,Int32}('A' => 1, 'G' => 2, 'C' => 3, 'T' => 4)
const PTR_NONE, PTR_GAP1, PTR_GAP2, PTR_BASE = 0:3

function seqalign(seq1, seq2, sub_mat, base_dict, gap_pen)
    n1 = length(seq1)
    n2 = length(seq2)
    F = zeros(Int32, n1+1, n2+1)
    TB = fill(PTR_NONE, (n1+1, n2+1))
    
    # Initialize the dynamic programming tables for Needleman-Wunsch
    for i in 1:n1
        F[i+1, 1] = 0 - i*gap_pen
        TB[i+1,1] = PTR_GAP2
    end
    for j in 1:n2
        F[1,j+1] = 0 - j*gap_pen
        TB[1,j+1] = PTR_GAP1
    end

    # Fill in the dynamic programming tables
    # seq1 are columns, seq2 are rows
    for i in 2:n2+1
        for j in 2:n1+1
            idx1, idx2 = base_dict[seq1[j-1]], base_dict[seq2[i-1]]
            s = sub_mat[idx1][idx2]
            diag = F[j-1,i-1] + s
            vert = F[j,i-1] - gap_pen
            horiz = F[j-1,i] - gap_pen
            F[j,i] = max(diag, vert, horiz)
            TB[j,i] = argmax([vert, horiz, diag])
        end
    end
    F[n1+1, n2+1], F, TB
end

function traceback(seq1, seq2, TB)
    s1 = ""
    s2 = ""

    i = length(seq1) + 1
    j = length(seq2) + 1

    while TB[i,j] != PTR_NONE
        if (TB[i,j] == PTR_BASE)
            s1 = seq1[i-1] * s1
            s2 = seq2[j-1] * s2
            i = i - 1
            j = j - 1
        elseif (TB[i,j] == PTR_GAP1)
            s1 = "-" * s1
            s2 = seq2[j-1] * s2
            j = j - 1
        elseif (TB[i,j] == PTR_GAP2)
            s1 = seq1[i-1] * s1
            s2 = "-" * s2
            i = i - 1
        else
            @assert false
        end
    end
    s1, s2
end

function readseq(filename)
    seq = []
    open(filename) do file
        for l in eachline(file)
            if (startswith(l, ">"))
                continue
            end
            append!(seq, rstrip(l))
        end
    end
    join(seq,"")
end
