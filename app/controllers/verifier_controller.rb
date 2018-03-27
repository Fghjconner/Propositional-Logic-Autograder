require "uri"
require "net/http"

class VerifierController < ApplicationController
    def index
    end
    
    def show
        params = {'premesis' => 'PvQ->R, P, @xFx, Fa&R->S', 'conclusion' => 'S', 'proof' => '1       (1) PvQ->R    A\n2       (2) P         A\n2       (3) PvQ       2 vI\n1,2     (4) R         1,3 ->E\n5       (5) @xFx      A\n5       (6) Fa        5 @E\n1,2,5   (7) Fa&R      4,6 &I\n8       (8) Fa&R->S   A\n1,2,8,5 (9) S         7,8 ->E', '.cgifields' => 'primitives_only'}
        @x = Net::HTTP.post_form(URI.parse('http://logic.tamu.edu/daemon.html'), params)
    end
end