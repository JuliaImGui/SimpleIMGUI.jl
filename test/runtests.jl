import SimpleIMGUI as SI
import SimpleDraw as SD
import Test

function draw_alignment_combinations!(image, color, total_height, total_width, padding, content_height, content_width)
    reference_bounding_box = SD.Rectangle(SD.Point(content_height + padding + one(padding), content_width + padding + one(padding)), total_height, total_width)
    SD.draw!(image, reference_bounding_box, color)

    for alignment in instances(SI.Alignment)
        content_bounding_box = SI.get_alignment_bounding_box(reference_bounding_box, alignment, padding, content_height, content_width)
        SD.draw!(image, content_bounding_box, color)
    end

    return nothing
end

Test.@testset "SimpleIMGUI.jl" begin
    Test.@testset "user input" begin
        Test.@testset "went_down" begin
            Test.@test SI.went_down(SI.InputButton(true, 0)) == false
            Test.@test SI.went_down(SI.InputButton(true, 1)) == true
            Test.@test SI.went_down(SI.InputButton(true, 2)) == true
            Test.@test SI.went_down(SI.InputButton(false, 0)) == false
            Test.@test SI.went_down(SI.InputButton(false, 1)) == false
            Test.@test SI.went_down(SI.InputButton(false, 2)) == true
        end

        Test.@testset "count_went_down" begin
            Test.@test SI.count_went_down(SI.InputButton(true, 0)) == 0
            Test.@test SI.count_went_down(SI.InputButton(true, 1)) == 1
            Test.@test SI.count_went_down(SI.InputButton(true, 2)) == 1
            Test.@test SI.count_went_down(SI.InputButton(true, 3)) == 2
            Test.@test SI.count_went_down(SI.InputButton(true, 4)) == 2
            Test.@test SI.count_went_down(SI.InputButton(false, 0)) == 0
            Test.@test SI.count_went_down(SI.InputButton(false, 1)) == 0
            Test.@test SI.count_went_down(SI.InputButton(false, 2)) == 1
            Test.@test SI.count_went_down(SI.InputButton(false, 3)) == 1
            Test.@test SI.count_went_down(SI.InputButton(false, 4)) == 2
        end

        Test.@testset "went_up" begin
            Test.@test SI.went_up(SI.InputButton(true, 0)) == false
            Test.@test SI.went_up(SI.InputButton(true, 1)) == false
            Test.@test SI.went_up(SI.InputButton(true, 2)) == true
            Test.@test SI.went_up(SI.InputButton(false, 0)) == false
            Test.@test SI.went_up(SI.InputButton(false, 1)) == true
            Test.@test SI.went_up(SI.InputButton(false, 2)) == true
        end

        Test.@testset "count_went_up" begin
            Test.@test SI.count_went_up(SI.InputButton(true, 0)) == 0
            Test.@test SI.count_went_up(SI.InputButton(true, 1)) == 0
            Test.@test SI.count_went_up(SI.InputButton(true, 2)) == 1
            Test.@test SI.count_went_up(SI.InputButton(true, 3)) == 1
            Test.@test SI.count_went_up(SI.InputButton(true, 4)) == 2
            Test.@test SI.count_went_up(SI.InputButton(false, 0)) == 0
            Test.@test SI.count_went_up(SI.InputButton(false, 1)) == 1
            Test.@test SI.count_went_up(SI.InputButton(false, 2)) == 1
            Test.@test SI.count_went_up(SI.InputButton(false, 3)) == 2
            Test.@test SI.count_went_up(SI.InputButton(false, 4)) == 2
        end

        Test.@testset "press" begin
            Test.@test SI.press(SI.InputButton(false, 0)) == SI.InputButton{Int64}(true, 1)
            Test.@test SI.press(SI.InputButton(false, 1)) == SI.InputButton{Int64}(true, 2)
            Test.@test SI.press(SI.InputButton(false, 2)) == SI.InputButton{Int64}(true, 3)
        end

        Test.@testset "release" begin
            Test.@test SI.release(SI.InputButton(true, 0)) == SI.InputButton{Int64}(false, 1)
            Test.@test SI.release(SI.InputButton(true, 1)) == SI.InputButton{Int64}(false, 2)
            Test.@test SI.release(SI.InputButton(true, 2)) == SI.InputButton{Int64}(false, 3)
        end

        Test.@testset "reset" begin
            Test.@test SI.reset(SI.InputButton(true, 0)) == SI.InputButton{Int64}(true, 0)
            Test.@test SI.reset(SI.InputButton(true, 1)) == SI.InputButton{Int64}(true, 0)
            Test.@test SI.reset(SI.InputButton(true, 2)) == SI.InputButton{Int64}(true, 0)
            Test.@test SI.press(SI.InputButton(false, 0)) == SI.InputButton{Int64}(true, 1)
            Test.@test SI.press(SI.InputButton(false, 1)) == SI.InputButton{Int64}(true, 2)
            Test.@test SI.press(SI.InputButton(false, 2)) == SI.InputButton{Int64}(true, 3)
        end
    end

    Test.@testset "Alignment" begin
        image_height = 32
        image_width = 64
        image = falses(image_height, image_width)
        color = true

        total_height = 21
        total_width = 32
        content_height = 3
        content_width = 6
        padding = 2

        draw_alignment_combinations!(image, color, total_height, total_width, padding, content_height, content_width)

        Test.@test image == BitArray([
1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 0 0 0 1 0 0 1 0 1 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 1 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
        ])

#=
   1 2 3 4 5 6 7 8 910111213141516171819202122232425262728293031323334353637383940414243444546474849505152535455565758596061626364
 1████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
 2██░░▒▒░░▒▒██▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒██▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
 3████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
 4▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
 5░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
 6████████████▒▒░░████████████████████████████████████████████████████████████████▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
 7██▒▒░░▒▒░░██░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
 8████████████▒▒░░██░░████████████▒▒░░▒▒░░▒▒████████████░░▒▒░░▒▒░░████████████▒▒██▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
 9░░▒▒░░▒▒░░▒▒░░▒▒██▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒██▒▒░░▒▒░░██░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
10▒▒░░▒▒░░▒▒░░▒▒░░██░░████████████▒▒░░▒▒░░▒▒████████████░░▒▒░░▒▒░░████████████▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
11░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
12▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
13░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
14▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
15████████████░░▒▒██▒▒████████████░░▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒████████████░░██░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
16██░░▒▒░░▒▒██▒▒░░██░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░██░░▒▒░░▒▒██▒▒██▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
17████████████░░▒▒██▒▒████████████░░▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒████████████░░██░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
18▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
19░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
20▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
21░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
22▒▒░░▒▒░░▒▒░░▒▒░░██░░████████████▒▒░░▒▒░░▒▒████████████░░▒▒░░▒▒░░████████████▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
23░░▒▒░░▒▒░░▒▒░░▒▒██▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒██▒▒░░▒▒░░██░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
24████████████▒▒░░██░░████████████▒▒░░▒▒░░▒▒████████████░░▒▒░░▒▒░░████████████▒▒██▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
25██▒▒░░▒▒░░██░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
26████████████▒▒░░████████████████████████████████████████████████████████████████▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
27░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
28▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
29████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
30██░░▒▒░░▒▒██▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒██▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
31████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
32▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
=#

        alignment = SI.UP2_LEFT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (-5, -8)
        alignment = SI.UP1_LEFT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (0, -8)
        alignment = SI.LEFT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (9, -8)
        alignment = SI.DOWN1_LEFT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (18, -8)
        alignment = SI.DOWN2_LEFT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (23, -8)

        alignment = SI.UP2_LEFT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (-5, 0)
        alignment = SI.UP1_LEFT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (2, 2)
        alignment = SI.LEFT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (9, 2)
        alignment = SI.DOWN1_LEFT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (16, 2)
        alignment = SI.DOWN2_LEFT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (23, 0)

        alignment = SI.UP2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (-5, 13)
        alignment = SI.UP1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (2, 13)
        alignment = SI.CENTER
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (9, 13)
        alignment = SI.DOWN1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (16, 13)
        alignment = SI.DOWN2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (23, 13)

        alignment = SI.UP2_RIGHT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (-5, 26)
        alignment = SI.UP1_RIGHT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (2, 24)
        alignment = SI.RIGHT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (9, 24)
        alignment = SI.DOWN1_RIGHT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (16, 24)
        alignment = SI.DOWN2_RIGHT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (23, 26)

        alignment = SI.UP2_RIGHT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (-5, 34)
        alignment = SI.UP1_RIGHT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (0, 34)
        alignment = SI.RIGHT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (9, 34)
        alignment = SI.DOWN1_RIGHT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (18, 34)
        alignment = SI.DOWN2_RIGHT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (23, 34)


        image_height = 32
        image_width = 64
        image = falses(image_height, image_width)
        color = true

        total_height = 22
        total_width = 33
        content_height = 3
        content_width = 6
        padding = 2

        draw_alignment_combinations!(image, color, total_height, total_width, padding, content_height, content_width)

        Test.@test image == BitArray([
1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1 1 0 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1 1 0 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 0 0 0 1 0 0 1 0 1 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1 1 0 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 0 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1 1 0 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 1 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
        ])

#=
   1 2 3 4 5 6 7 8 910111213141516171819202122232425262728293031323334353637383940414243444546474849505152535455565758596061626364
 1████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░████████████▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
 2██░░▒▒░░▒▒██▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░██░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
 3████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░████████████▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
 4▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
 5░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
 6████████████▒▒░░██████████████████████████████████████████████████████████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
 7██▒▒░░▒▒░░██░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
 8████████████▒▒░░██░░████████████▒▒░░▒▒░░▒▒████████████░░▒▒░░▒▒░░▒▒████████████░░██░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
 9░░▒▒░░▒▒░░▒▒░░▒▒██▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒██▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
10▒▒░░▒▒░░▒▒░░▒▒░░██░░████████████▒▒░░▒▒░░▒▒████████████░░▒▒░░▒▒░░▒▒████████████░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
11░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
12▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
13░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
14▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
15████████████░░▒▒██▒▒████████████░░▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒░░████████████▒▒██▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
16██░░▒▒░░▒▒██▒▒░░██░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░██░░██░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
17████████████░░▒▒██▒▒████████████░░▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒░░████████████▒▒██▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
18▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
19░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
20▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
21░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
22▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
23░░▒▒░░▒▒░░▒▒░░▒▒██▒▒████████████░░▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒░░████████████▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
24▒▒░░▒▒░░▒▒░░▒▒░░██░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒██▒▒░░▒▒░░██░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
25████████████░░▒▒██▒▒████████████░░▒▒░░▒▒░░████████████▒▒░░▒▒░░▒▒░░████████████▒▒██▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
26██░░▒▒░░▒▒██▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
27████████████░░▒▒██████████████████████████████████████████████████████████████████▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
28▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
29░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
30████████████▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
31██▒▒░░▒▒░░██░░▒▒██▒▒░░▒▒░░██░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░██░░▒▒░░▒▒██▒▒░░██░░▒▒░░▒▒██▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒
32████████████▒▒░░████████████▒▒░░▒▒░░▒▒░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒████████████░░▒▒████████████░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░▒▒░░
=#

        alignment = SI.UP2_LEFT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (-5, -8)
        alignment = SI.UP1_LEFT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (0, -8)
        alignment = SI.LEFT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (9, -8)
        alignment = SI.DOWN1_LEFT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (19, -8)
        alignment = SI.DOWN2_LEFT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (24, -8)

        alignment = SI.UP2_LEFT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (-5, 0)
        alignment = SI.UP1_LEFT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (2, 2)
        alignment = SI.LEFT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (9, 2)
        alignment = SI.DOWN1_LEFT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (17, 2)
        alignment = SI.DOWN2_LEFT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (24, 0)

        alignment = SI.UP2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (-5, 13)
        alignment = SI.UP1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (2, 13)
        alignment = SI.CENTER
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (9, 13)
        alignment = SI.DOWN1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (17, 13)
        alignment = SI.DOWN2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (24, 13)

        alignment = SI.UP2_RIGHT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (-5, 27)
        alignment = SI.UP1_RIGHT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (2, 25)
        alignment = SI.RIGHT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (9, 25)
        alignment = SI.DOWN1_RIGHT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (17, 25)
        alignment = SI.DOWN2_RIGHT1
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (24, 27)

        alignment = SI.UP2_RIGHT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (-5, 35)
        alignment = SI.UP1_RIGHT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (0, 35)
        alignment = SI.RIGHT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (9, 35)
        alignment = SI.DOWN1_RIGHT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (19, 35)
        alignment = SI.DOWN2_RIGHT2
        Test.@test SI.get_alignment_offset(total_height, total_width, alignment, padding, content_height, content_width) == (24, 35)
    end

    Test.@testset "get_enclosing_bounding_box" begin
        Test.@test SI.get_enclosing_bounding_box(SD.Rectangle(SD.Point(2, 3), 4, 5), SD.Rectangle(SD.Point(4, 5), 6, 7)) == SD.Rectangle(SD.Point(2, 3), 8, 9)
    end
end
