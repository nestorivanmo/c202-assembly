defmodule Parser do

	def parse(otl, gast) do
		ps_m = generatePossibleStructureMap(gast)
		root_AST = generateRootAST()
		{result_token, oast, tl, error_cause} = myStructureMatches(root_AST, otl, ps_m)
		if result_token === :ok and tl === [] do
			{:ok,oast,tl,error_cause}
		else
			if result_token === :error do
				{:token_missing_error,oast,tl,error_cause}
			else
				{:token_not_absorbed_error,oast,tl,error_cause}
			end
		end
	end

	defp myStructureMatches(cs,tl,ps_m) do
		{result_token_1, tl_1, absorbed_token} = myTokenMatches(cs,tl)
		if result_token_1 === :ok do
			{result_token_2, tl_2, children_list,error_cause} = myChildrenMatch(cs,tl_1,ps_m)
			if result_token_2 === :ok do
				d_cs = specifizeStructure(cs,absorbed_token,children_list)
				{:ok,d_cs,tl_2,nil}
			else
				#there was no if
				if error_cause === nil do
					{:error,cs,tl,cs}
				else
					{:error,cs,tl,error_cause}
				end
				#{:error,cs,tl,incoming_error} #:structure-does-not-match-expectation
			end
		else
			{:error,cs,tl,nil} #:Could not absorb token of structure
		end
	end
	
	defp myChildrenMatch(cs,tl,ps_m) do
		children_list = cs.children
		nextChildMatch(children_list,tl,[],ps_m)
	end
	
	defp nextChildMatch([],tl,previous_children,_ps_m) do
		{:ok, tl, previous_children, nil}
	end
	defp nextChildMatch(cl,tl,previous_children,ps_m) do
		[child | cl_1] = cl
		possible_structures = ps_m[child["class"]]
		{result_token, matched_structure, tl_1, incoming_error} = checkPS(possible_structures,tl,nil,ps_m)
		if result_token === :ok do
			nextChildMatch(cl_1,tl_1,previous_children++[matched_structure],ps_m)
		else
			{:error,tl,previous_children++[child],incoming_error}
			#if incoming_error === nil do
			#	{:error,tl,previous_children++[child],child}
			#else
			#	{:error,tl,previous_children++[child],incoming_error}
			#end
		end
	end		
	
	defp checkPS([],tl,error_cause,_ps_m) do
		{:error,nil,tl,error_cause}
	end
	defp checkPS(ps,tl,_error_cause,ps_m) do
		[candidate_structure | ps_1] = ps
		{result_token,current_candidate,tl_1,error_cause_1} = myStructureMatches(candidate_structure,tl,ps_m)
		if result_token === :ok do 
			{:ok,current_candidate,tl_1,nil}
		else
			checkPS(ps_1,tl,error_cause_1,ps_m)
		end

	end
	defp myTokenMatches(cs,[]) do
		if cs.token === nil do
			{:ok,[],nil}
		else
				{:error,[],nil}
		end
	end
	defp myTokenMatches(cs,tl) do
		[absorbed_token | tl_1] = tl
		if cs.token === nil do
			{:ok,tl,nil}
		else
			if cs.token === absorbed_token.tag do
				{:ok,tl_1,absorbed_token}
			else
				{:error,tl,absorbed_token}
			end
			
		end
	end
	defp specifizeStructure(cs,absorbed_token,children_list) do
		%Structs.Node{
			class: cs.class, 
			token: absorbed_token, 
			tag: cs.tag, 
			asm: cs.asm, 
			children: children_list
		}
	end
	defp generatePossibleStructureMap(gast) do
		keys = (Enum.map(gast, fn x -> [x.class] end) |> List.flatten |> Enum.uniq)
		Enum.map(keys, fn k -> {k,Enum.filter(gast, fn y -> Enum.member?(List.flatten([y.class]),k) end)} end)
		|> Map.new
	end
	defp generateRootAST() do
		%Structs.Node{
			class: :root,
			token: nil,
			tag: :root,
			children: [%{"class"=>"program-root", "tag"=>"program-root"}],
			asm: "mov :r, :0"
		}
	end
end
